<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="/tei:TEI">
        <xsl:variable name="id">http://papyri.info/hgv/<xsl:value-of select="//tei:publicationStmt/tei:idno[@type='filename']"/>/source</xsl:variable>
        <xsl:variable name="bibl" select="//tei:div[@type='bibliography']//tei:bibl[@type='publication' and @subtype='principal']"/>
        <xsl:variable name="title" select="replace(normalize-unicode(replace($bibl/tei:title[@level='s'],'\s','_'), 'NFD'), '[^._a-zA-Z]', '')"/>
        <rdf:Description rdf:about="{$id}">
            <dcterms:identifier>papyri.info/hgv/<xsl:value-of select="//tei:publicationStmt/tei:idno[@type='filename']"/></dcterms:identifier>
            <xsl:for-each select="//tei:publicationStmt/tei:idno[@type='TM']">
                <dcterms:identifier>tm:<xsl:value-of select="."/></dcterms:identifier>
            </xsl:for-each>
            <dcterms:identifier>
                <rdf:Description>
                    <xsl:attribute name="rdf:about">http://papyri.info/hgv/<xsl:value-of select="$title"/><xsl:if test="$bibl//tei:biblScope[@type='volume']">_<xsl:value-of select="$bibl//tei:biblScope[@type='volume']"/></xsl:if><xsl:if test="$bibl//tei:biblScope[@type='numbers']">_<xsl:value-of select="$bibl//tei:biblScope[@type='numbers']"/></xsl:if><xsl:for-each select="$bibl//tei:biblScope[@type='parts']">_<xsl:value-of select="encode-for-uri(.)"/></xsl:for-each></xsl:attribute>
                    <dcterms:identifier rdf:resource="{$id}"/>
                </rdf:Description>
            </dcterms:identifier>
            <dcterms:isPartOf>
                <xsl:choose>
                    <xsl:when test="$bibl//tei:biblScope[@type='volume']">
                        <rdf:Description rdf:about="http://papyri.info/hgv/{$title}_{normalize-space($bibl//tei:biblScope[@type='volume'])}">
                            <dcterms:isPartOf>
                                <rdf:Description rdf:about="http://papyri.info/hgv/{$title}">
                                    <dcterms:isPartOf rdf:resource="http://papyri.info/hgv"/>
                                </rdf:Description>
                            </dcterms:isPartOf>
                        </rdf:Description>
                    </xsl:when>
                    <xsl:otherwise>
                        <rdf:Description rdf:about="http://papyri.info/hgv/{$title}">
                            <dcterms:isPartOf rdf:resource="http://papyri.info/hgv"/>
                        </rdf:Description>
                    </xsl:otherwise>
                </xsl:choose>
            </dcterms:isPartOf>
            <xsl:if test="//tei:publicationStmt/tei:idno[@type='ddb-hybrid']">
                <xsl:variable name="ddb" select="tokenize(normalize-space(//tei:publicationStmt/tei:idno[@type='ddb-hybrid']), ';')"/>
                <dcterms:relation>
                    <rdf:Description rdf:about="http://papyri.info/ddbdp/{$ddb[1]};{$ddb[2]};{encode-for-uri($ddb[3])}/source">
                        <dcterms:relation rdf:resource="{$id}"/>
                    </rdf:Description>
                </dcterms:relation>
            </xsl:if>
            <xsl:for-each select="//tei:text/tei:body/tei:div[@type='figure']//tei:graphic[starts-with(@url, 'http://wwwapp.cc.columbia.edu')]">
                <dcterms:relation>
                    <rdf:Description rdf:about="http://papyri.info/apis/{normalize-space(substring-after(@url, 'key='))}/source">
                        <dcterms:relation rdf:resource="{$id}"/>
                    </rdf:Description>
                </dcterms:relation>
            </xsl:for-each>
            <dcterms:source>
                <rdf:Description rdf:about="http://papyri.info/hgv/{//tei:publicationStmt/tei:idno[@type='filename']}/frbr:Work">
                    <dcterms:bibliographicCitation><xsl:value-of select="$bibl/tei:title[@level='s']"/><xsl:if test="$bibl//tei:biblScope[@type='volume']"><xsl:text> </xsl:text><xsl:value-of select="$bibl//tei:biblScope[@type='volume']"/></xsl:if><xsl:if test="$bibl//tei:biblScope[@type='numbers']">, <xsl:value-of select="$bibl//tei:biblScope[@type='numbers']"/></xsl:if><xsl:if test="$bibl//tei:biblScope[@type='parts']">, <xsl:value-of select="$bibl//tei:biblScope[@type='parts']"/></xsl:if></dcterms:bibliographicCitation>
                <xsl:for-each select="//tei:text/tei:body//tei:bibl[@type='publication'][@subtype='other']">
                    <dcterms:relation><xsl:value-of select="."/></dcterms:relation>
                </xsl:for-each>
                </rdf:Description>
            </dcterms:source>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="TEI.2"/>
</xsl:stylesheet>
