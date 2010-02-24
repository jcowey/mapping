;; Load a local file into the store
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
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation Command CreateGraph Load)))
      
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
           
(defn -main
  [args]
  (let [factory (ConnectionFactory.)
        conn (.newConnection factory server)
        file (File. (first args))]
      (.execute conn (CreateGraph. graph))
      (.execute (Load. (.toURI file) graph, true) conn)
      (.close conn)))
      
(-main (rest *command-line-args*))
           
         