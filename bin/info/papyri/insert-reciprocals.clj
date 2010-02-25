;; Load a local file into the store
(ns info.papyri.map
  (:gen-class)
  (:import (java.io File)
           (java.net URI)
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation CreateGraph Insertion)
           (org.mulgara.sparql SparqlInterpreter)))
           
      
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
           
(defn -main
  [args]
  (def insert "prefix dc: <http://purl.org/dc/terms/> 
    construct{?s dc:hasPart ?o} 
    from <rmi://localhost/papyri.info#pi> 
    where { ?o dc:isPartOf ?s}")
  (let [factory (ConnectionFactory.)
        conn (.newConnection factory server)
        interpreter (SparqlInterpreter.)]
      (.execute conn (CreateGraph. graph))
      (.execute (Insertion. graph, (.parseQuery interpreter insert)) conn)
      (.close conn)))
      
(-main (rest *command-line-args*))
           
