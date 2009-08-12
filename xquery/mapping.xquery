(: ZAU IDP Map Maker :)
xquery version "1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tei2="http://www.stoa.org/epidoc/dtd/6/tei-epidoc.dtd";

<maps>
    {
    (: Creates an entry for every single DDB XML file:)
    for $file in collection('file:///C:/Users/Atenaz/Documents/IDP/ddb/?recurse=yes;select=*.xml')
        let $teiHeader := $file//tei:teiHeader
        let $fileid := $teiHeader//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()
        let $associatedHGVString := $teiHeader//tei:titleStmt/tei:title/@n
        let $teiText := $file//tei:text
        return
        
        <map>
            <ddbdp_hybrid>{$fileid}</ddbdp_hybrid>
            <ddbdp_perseus>{$teiHeader//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style']/text()}</ddbdp_perseus>
            <ddbdp_readable>{$teiHeader//tei:publicationStmt/tei:idno[@type = 'filename']/text()}</ddbdp_readable>
            {
            (: Finds associated HGV files:)
                for $associatedHGV in tokenize($associatedHGVString, "\s")
                    return
                        <associated_hgv>{$associatedHGV}</associated_hgv>
            }
            {
            (: Reprints:)
                for $reprintIn in $file//tei:text/tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-in']
                    return 
                        <reprint_in>{string($reprintIn/@n)}</reprint_in>     
            }  
            {
                if (exists($teiText/tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-from']))
                then
                    
                    let $reprintFromString := string($teiText/tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-from']/@n)
                    for $reprintFrom in tokenize($reprintFromString, '\|')
                        return
                            <reprint_from>{$reprintFrom}</reprint_from>     
                else string('')
            }
            {
            (: Pulls information from HGV metadata files that match the DDB file :)
                for $HGVfile in collection('file:///C:/Users/Atenaz/Documents/IDP/hgv/?recurse=yes;select=*.xml')/TEI.2[@n = $fileid]
                    let $hgv := $HGVfile/@id
                    return
                    (
                        <tm>{$HGVfile//text/body/div/listBibl/bibl[@type='Trismegistos']/biblScope/text()}</tm>,
                        <hgv>{substring-after($hgv, 'hgv')}</hgv>,
                        (: Publication :)
                        if (exists($HGVfile//text/body//bibl[@type='publication'][@subtype='other']))
                        then
                            for $otherBibl in $HGVfile//text/body//bibl[@type='publication'][@subtype='other']
                            return
                            <anderePubl>{$otherBibl/text()}</anderePubl>
                        else string(''),
                        (: APIS image :)
                        if (exists($HGVfile//text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]))
                        then
                            <apis>{substring-after($HGVfile//text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]/@href, 'key=')}</apis>
                        else string('')
                    )
            }
            {
            (: Pulls HGV translation file ID that matches the DDB file :)
                for $HGVtrans in collection('file:///C:/Users/Atenaz/Documents/IDP/hgvTrans/?recurse=yes;select=*.xml')/TEI.2[@n = $fileid]
                    return
                        <trans>{string($HGVtrans/@id)}</trans>
            }
        </map>
    }

    {
    (: Creates a stub entry for all remaining HGV files:)
        let $DDBCollection := collection('file:///C:/Users/Atenaz/Documents/IDP/ddb/?recurse=yes;select=*.xml')//tei:TEI//tei:teiHeader//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()
        for $HGVStub in collection('file:///C:/Users/Atenaz/Documents/IDP/hgv/?recurse=yes;select=*.xml')/TEI.2[not(@n = $DDBCollection)]
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
                        if (exists($HGVStub/text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]))
                        then
                            <apis>{substring-after($HGVStub/text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]/@href, 'key=')}</apis>
                        else string('')
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