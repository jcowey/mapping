xquery version "1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare variable $ddbUrl := "../../../idp.data/branches/p5-test/DDB_EpiDoc_XML/?recurse=yes;select=*.xml";

<maps>
  {
    (: Creates a stub entry for all remaining HGV files:)
        let $DDBCollection := collection($ddbUrl)//tei:TEI//tei:teiHeader//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()
        for $HGVStub in collection('../../../idp.data/trunk/HGV_meta_EpiDoc/?recurse=yes;select=*.xml')/TEI.2[not(@n = $DDBCollection)]
        let $name := document-uri($HGVStub/..)
        let $HGVidno := substring-after($HGVStub/@id, 'hgv')
            return
                <map>
                    <tm>{$HGVStub//text/body/div/listBibl/bibl[@type='Trismegistos']/biblScope/text()}</tm>
                    <hgv>{$HGVidno}</hgv>
                    {
                    (: Publication :)
                        if (exists($HGVStub/text/body/div[@type='bibliography'][@subtype='otherPublications']))
                        then
                            $HGVStub/text/body/div[@type='bibliography'][@subtype='otherPublications']
                        else string('')
                    }
                    {
                    (: APIS image :)
                        for $figure in $HGVStub/text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]
                        return
                            <apis>{substring-after($figure/@href, 'key=')}</apis>
                    }
                    <error>No DDB match</error>        
                    {
                    if (not(ends-with(substring-before($name, '.xml'), $HGVidno)))
                    then
                        <error>Filename does not match @id: {$name}</error>
                    else string('')
                    }    
                    {
                    if (ends-with($HGVStub/@n, ';') or starts-with($HGVStub/@n, ';'))
                    then
                        <error>Check DDB reference @n: {string($HGVStub/@n)}</error>
                    else string('')
                    }
                </map>
    }
</maps>
