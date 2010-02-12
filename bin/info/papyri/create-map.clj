; Recursively read a directory full of XML and produce a map file from it, using a provided XSLT
(ns info.papyri.map
  (:gen-class)
  (:import (java.io BufferedReader ByteArrayInputStream ByteArrayOutputStream File FileInputStream FileOutputStream FileReader StringWriter)
           (java.net URI)
           (java.nio.charset Charset)
           (java.util.concurrent Executors ConcurrentLinkedQueue)
           (javax.activation MimeType)
           (javax.xml.transform Templates Transformer)
           (javax.xml.transform.stream StreamSource StreamResult)
           (net.sf.saxon Configuration FeatureKeys PreparedStylesheet StandardErrorListener StandardURIResolver TransformerFactoryImpl)
           (net.sf.saxon.trans CompilerInfo XPathException)
           (org.apache.xml.resolver.tools CatalogResolver ResolvingXMLReader)
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation Command CreateGraph Load)))
           
(def templates (ref nil))
(def output (ref nil))
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
(def param (ref nil))

(defn transform
  [file]
  (let [xslt (.poll @templates)
        transformer (.newTransformer xslt)
        out (StringWriter.)
        outstr (StreamResult. out)
        factory (ConnectionFactory.)
        conn (.newConnection factory server)]
    (try
      (if (not (nil? @param))
        (doto transformer
          (.setParameter (first @param) (second @param))))
      (.transform transformer (StreamSource. (FileInputStream. file)) outstr)
      ;; (println (.toString (.getBuffer out)))
      (.execute (Load. graph (ByteArrayInputStream. (.getBytes (.toString (.getBuffer out)) (Charset/forName "UTF-8"))) (MimeType. "application/rdf+xml")) conn)
      (.close conn)
      (catch Exception e 
        (.println *err* (str (.getMessage e) " processing file " file))))
    (.add @templates xslt)))

(defn init-templates
    [xslt, param, nthreads]
  (dosync (ref-set templates (ConcurrentLinkedQueue.) ))
  (dotimes [n nthreads]
    (let [xsl-src (StreamSource. (FileInputStream. xslt))
            configuration (Configuration.)
            compiler-info (CompilerInfo.)]
          (doto xsl-src 
            (.setSystemId xslt))
          (doto configuration
            (.setURIResolver (CatalogResolver.))
            (.setConfigurationProperty FeatureKeys/SOURCE_PARSER_CLASS "org.apache.xml.resolver.tools.ResolvingXMLReader"))
          (doto compiler-info
            (.setErrorListener (StandardErrorListener.))
            (.setURIResolver (StandardURIResolver. configuration)))
          (dosync (.add @templates (PreparedStylesheet/compile xsl-src configuration compiler-info))))))

(defn -main
  ([args]
    (def dirs (file-seq (File. (first args))))
    (def nthreads 20)
    (if (== 3 (count args))
      (dosync (ref-set param (.split (nth args 2) "="))))
    (init-templates (second args) param nthreads)
    (let [factory (ConnectionFactory.)
          conn (.newConnection factory server)
          create (CreateGraph. graph)]
        (.execute conn create)
        (.close conn))
    (let [pool (Executors/newFixedThreadPool nthreads)
          tasks (map (fn [x]
      (fn []
        (transform x)))
      (filter #(.endsWith (.getName %) ".xml") dirs))]
      (doseq [future (.invokeAll pool tasks)]
        (.get future))
      (doto pool
        (.shutdown)))))

      
(-main (rest *command-line-args*))
  
