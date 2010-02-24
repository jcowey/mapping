<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="/tei:TEI">
        <xsl:variable name="ddb-seq" select="tokenize(normalize-space(//tei:publicationStmt/tei:idno[@type='ddb-hybrid']), ';')"/>
        <xsl:variable name="id">http://papyri.info/ddbdp/<xsl:value-of select="replace(normalize-unicode($ddb-seq[1], 'NFD'), '[^.a-z0-9]', '')"/>;<xsl:value-of select="$ddb-seq[2]"/>;<xsl:value-of select="encode-for-uri($ddb-seq[3])"/>/source</xsl:variable>
        <xsl:variable name="tmids" select="distinct-values(tokenize(replace(//tei:titleStmt/tei:title/@n, '[a-z]', ''), '\s'))"/>
        <rdf:Description rdf:about="{$id}">
            <dcterms:identifier>papyri.info/ddbdp/<xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()"/></dcterms:identifier>
            <dcterms:identifier><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style']/text()"/></dcterms:identifier>
            <dcterms:identifier><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'filename']/text()"/></dcterms:identifier>
            <xsl:for-each select="distinct-values(//tei:text/tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-in']/@n)">
                <xsl:for-each select="tokenize(., '\|')">
                <xsl:variable name="ddb-reprint-seq" select="tokenize(., ';')"/>
                <xsl:if test="matches(., '(\w|\.);\d*;.+')">
                    <dcterms:isReplacedBy rdf:resource="http://papyri.info/ddbdp/{$ddb-reprint-seq[1]};{$ddb-reprint-seq[2]};{encode-for-uri($ddb-reprint-seq[3])}/source"/>
                </xsl:if>
            </xsl:for-each>
            </xsl:for-each>
            
            <xsl:for-each select="tokenize(//tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-from']/@n, '\|')">
                <xsl:variable name="ddb-reprint-seq" select="tokenize(., ';')"/>
                <xsl:if test="matches(., '(\w|\.);\d*;.+')">    
                    <dcterms:replaces rdf:resource="http://papyri.info/ddbdp/{$ddb-reprint-seq[1]};{$ddb-reprint-seq[2]};{encode-for-uri($ddb-reprint-seq[3])}/source"/>
                </xsl:if>
            </xsl:for-each>
            <dcterms:isPartOf>
                <xsl:choose>
                    <xsl:when test="$ddb-seq[2] = ''">
                        <rdf:Description rdf:about="http://papyri.info/ddbdp/{$ddb-seq[1]}">
                            <dcterms:isPartOf rdf:resource="http://papyri.info/ddbdp"/>
                        </rdf:Description>
                    </xsl:when>
                    <xsl:otherwise>
                        <rdf:Description rdf:about="http://papyri.info/ddbdp/{$ddb-seq[1]};{$ddb-seq[2]}">
                            <dcterms:isPartOf>
                                <rdf:Description rdf:about="http://papyri.info/ddbdp/{$ddb-seq[1]}">
                                    <dcterms:isPartOf rdf:resource="http://papyri.info/ddbdp"/>
                                </rdf:Description>
                            </dcterms:isPartOf>
                        </rdf:Description>
                    </xsl:otherwise>
                </xsl:choose>
            </dcterms:isPartOf>
            <xsl:for-each select="tokenize(//tei:titleStmt/tei:title/@n, '\s')">
                <dcterms:relation>
                    <rdf:Description rdf:about="http://papyri.info/hgv/{.}/source">
                        <dcterms:relation rdf:resource="{$id}"/>
                        <xsl:for-each select="$tmids">
                            <dcterms:identifier>tm:<xsl:value-of select="."/></dcterms:identifier>
                        </xsl:for-each>
                    </rdf:Description>
                </dcterms:relation>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>
</xsl:stylesheet>
