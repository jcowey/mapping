(: ZAU IDP Map Maker :)
xquery version "1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tei2="http://www.stoa.org/epidoc/dtd/6/tei-epidoc.dtd";
declare variable $hgvColl := collection('../../../idp.data/trunk/HGV_meta_EpiDoc/?recurse=yes;select=*.xml');
declare variable $hgvtColl := collection('../../../idp.data/trunk/HGV_trans_EpiDoc/?recurse=yes;select=*.xml');
declare variable $ddbUrl := "../../../idp.data/branches/p5-test/DDB_EpiDoc_XML/?recurse=yes;select=*.xml";
declare variable $ddbIds := ();

<maps>
    {
    
    (: Creates an entry for every single DDB XML file:)
    for $file in collection($ddbUrl)
        let $teiHeader := $file//tei:teiHeader
        let $fileid := $teiHeader//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()
        let $ddbIds := distinct-values(($ddbIds, $fileid))
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
                for $HGVfile in $hgvColl/TEI.2[@n = $fileid]
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
                        for $figure in $HGVfile/text/body/div[@type='figure']//figure[starts-with(@href, 'http://wwwapp.cc.columbia.edu')]
                        return
                            <apis>{substring-after($figure/@href, 'key=')}</apis>
                    )
            }
            {
            (: Pulls HGV translation file ID that matches the DDB file :)
                for $HGVtrans in $hgvtColl/TEI.2[@n = $fileid]
                    return
                        <trans>{string($HGVtrans/@id)}</trans>
            }
        </map>
    }
</maps>