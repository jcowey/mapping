<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    exclude-result-prefixes="xs tei" version="2.0">
    
    <xsl:template match="/tei:TEI">
        <xsl:variable name="id">http://papyri.info/hgv/<xsl:value-of select="//tei:publicationStmt/tei:idno[@type='HGV']"/>/source</xsl:variable>
        <xsl:variable name="bibl" select="//tei:div[@type='bibliography']//tei:bibl[@type='publication' and @subtype='principal']"/>
        <xsl:variable name="title" select="encode-for-uri($bibl/tei:title[@level='s'])"/>
        <rdf:RDF>
            <rdf:Description rdf:about="{$id}">
                <dcterms:identifier>papyri.info/hgv/<xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'HGV']/text()"/></dcterms:identifier>
                <dcterms:identifier>tm:<xsl:value-of select="//tei:publicationStmt/tei:idno[@type='TM']"/></dcterms:identifier>
                <dcterms:isPartOf>
                    <xsl:choose>
                        <xsl:when test="$bibl//tei:biblScope[@type='volume']">
                            <rdf:Description rdf:about="http://papyri.info/hgv/{$title}%20{$bibl//tei:biblScope[@type='volume']}">
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
                    <dcterms:relation>
                        <rdf:Description rdf:about="http://papyri.info/ddbdp/{//tei:publicationStmt/tei:idno[@type='ddb-hybrid']}/source">
                            <dcterms:relation rdf:resource="{$id}"/>
                        </rdf:Description>
                    </dcterms:relation>
                </xsl:if>
                <xsl:for-each select="//tei:text/tei:body/tei:div[@type='figure']//tei:graphic[starts-with(@url, 'http://wwwapp.cc.columbia.edu')]">
                    <dcterms:relation>
                        <rdf:Description rdf:about="http://papyri.info/apis/{substring-after(@url, 'key=')}/source">
                            <dcterms:relation rdf:resource="{$id}"/>
                        </rdf:Description>
                    </dcterms:relation>
                </xsl:for-each>
                <dcterms:source rdf:nodeID="publication"/>
            </rdf:Description>
            
            <rdf:Description rdf:nodeID="publication">
                <dcterms:bibliographicCitation><xsl:value-of select="$bibl/tei:title[@level='s']"/><xsl:if test="$bibl//tei:biblScope[@type='volume']"><xsl:text> </xsl:text><xsl:value-of select="$bibl//tei:biblScope[@type='volume']"/></xsl:if><xsl:if test="$bibl//tei:biblScope[@type='numbers']">, <xsl:value-of select="$bibl//tei:biblScope[@type='numbers']"/></xsl:if><xsl:if test="$bibl//tei:biblScope[@type='parts']">, <xsl:value-of select="$bibl//tei:biblScope[@type='parts']"/></xsl:if></dcterms:bibliographicCitation>
                <xsl:for-each select="//tei:text/tei:body//tei:bibl[@type='publication'][@subtype='other']">
                    <dcterms:relation><xsl:value-of select="."/></dcterms:relation>
                </xsl:for-each>
            </rdf:Description>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>
