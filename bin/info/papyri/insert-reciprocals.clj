;; Run some queries that infer new relationships based on existing ones
;; and insert the results into the database.
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
  (if (> (count args) 0)
    (let [factory (ConnectionFactory.)
	  conn (.newConnection factory server)
	  interpreter (SparqlInterpreter.)
	  url (first args)]
      (.execute conn (CreateGraph. graph))
      (.execute
       (Insertion. graph,
		   (.parseQuery interpreter
				(str "prefix dc: <http://purl.org/dc/terms/> "
				     "construct{?s dc:hasPart <" url ">} "
				     "from <rmi://localhost/papyri.info#pi> "
				     "where { <" url "> dc:isPartOf ?s}"))) conn)
      (.execute
       (Insertion. graph,
		   (.parseQuery interpreter
				(str "prefix dc: <http://purl.org/dc/terms/> "
				     "construct{?s dc:relation <" url ">} "
				     "from <rmi://localhost/papyri.info#pi> "
				     "where { <" url "> dc:relation ?s}"))) conn)
      (.execute
       (Insertion. graph,
		   (.parseQuery interpreter
				(str "prefix dc: <http://purl.org/dc/terms/> "
				     "construct{<" url "> dc:relation ?o2} "
				     "from <rmi://localhost/papyri.info#pi> "
				     "where { <" url "> dc:relation ?o1 . "
				     "?o1 dc:relation ?o2 "
				     "filter (!sameTerm(<" url ">, ?o2))}"))) conn)
      (.close conn))
    (let [factory (ConnectionFactory.)
	  conn (.newConnection factory server)
	  interpreter (SparqlInterpreter.)]
      (def hasPart (str "prefix dc: <http://purl.org/dc/terms/> "
			"construct{?s dc:hasPart ?o} "
			"from <rmi://localhost/papyri.info#pi> "
			"where { ?o dc:isPartOf ?s}"))
      (def relation "prefix dc: <http://purl.org/dc/terms/> 
      construct{?s dc:relation ?o} 
      from <rmi://localhost/papyri.info#pi> 
      where { ?o dc:relation ?s}")
      (def translations "prefix dc: <http://purl.org/dc/terms/>
      construct { ?r1 <http://purl.org/dc/terms/relation> ?r2 }
      from <rmi://localhost/papyri.info#pi>
      where {
      ?i dc:relation ?r1 .
      ?i dc:relation ?r2 .
      FILTER  regex(str(?i), \"^http://papyri.info/hgv\") 
      FILTER  regex(str(?r1), \"^http://papyri.info/ddbdp\")
      FILTER  regex(str(?r2), \"^http://papyri.info/hgvtrans\")}")
      (def images "prefix dc: <http://purl.org/dc/terms/>
      construct { ?r1 <http://purl.org/dc/terms/relation> ?r2 }
      from <rmi://localhost/papyri.info#pi>
      where {
      ?c dc:isPartOf <http://papyri.info/apis> .
      ?i dc:isPartOf ?c .
      ?i dc:relation ?r1 .
      ?i dc:relation ?r2 .
      FILTER ( regex(str(?r1), \"^http://papyri.info/ddbdp\") || regex(str(?r1), \"^http://papyri.info/hgv\")) 
      FILTER  regex(str(?r2), \"^http://papyri.info/images\")}")
      (def transitive-rels "prefix dc: <http://purl.org/dc/terms/>
      construct{?s dc:relation ?o2}
      from <rmi://localhost/papyri.info#pi>
      where { ?s dc:relation ?o1 .
              ?o1 dc:relation ?o2 
              filter (!sameTerm(?s, ?o2))}")
      (.execute conn (CreateGraph. graph))
      (.execute (Insertion. graph, (.parseQuery interpreter hasPart)) conn)
      (.execute (Insertion. graph, (.parseQuery interpreter relation)) conn)
      (.execute (Insertion. graph, (.parseQuery interpreter translations)) conn)
      (.execute (Insertion. graph, (.parseQuery interpreter images)) conn)
      (.execute (Insertion. graph, (.parseQuery interpreter transitive-rels)) conn)
      (.close conn))))
      
(-main (rest *command-line-args*))
