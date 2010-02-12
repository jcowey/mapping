<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    <xsl:param name="DDB-root">/Users/hcayless/Development/APIS/idp/idp.data/trunk/DDB_EpiDoc_XML</xsl:param>
    <xsl:param name="HGV-root"/>
    
    <xsl:template match="/tei:TEI">
        <record>
            <id type="apis"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'apisid']/text()"/></id>
            <id type="invno"><xsl:value-of select="//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno"/></id>
            <xsl:for-each select="//tei:bibl[@type = 'ddbdp']">
                <xsl:variable name="ddb-seq" select=" tokenize(., ':')"/>
                <xsl:variable name="col" select="replace(lower-case($ddb-seq[1]),'\.$','')"/>
                <xsl:variable name="ddb-doc-uri">
                    <xsl:choose>
                        <xsl:when test="count($ddb-seq) = 2"><xsl:value-of select="concat($DDB-root, '/', $col, '/', $col, '.', $ddb-seq[2], '.xml')"/></xsl:when>
                        <xsl:when test="count($ddb-seq) = 3"><xsl:value-of select="concat($DDB-root, '/', $col, '/', $col, '.', $ddb-seq[2], '/', $col, '.', $ddb-seq[2], '.', $ddb-seq[3], '.xml')"/></xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="ddb-doc">
                    <xsl:if test="doc-available($ddb-doc-uri)"><xsl:copy-of select="document($ddb-doc-uri)"/></xsl:if>
                </xsl:variable>
                <xsl:if test="$ddb-doc != ''">
                    <id type="ddbdp_hybrid" collection="{substring-before($ddb-doc//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid'], ';')}" 
                        vol="{substring-before(substring-after($ddb-doc//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid'],';'), ';')}"
                        item="{substring-after(substring-after($ddb-doc//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid'],';'),';')}"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'ddb-hybrid']/text()"/></id>
                    <id type="ddbdp_perseus"><xsl:value-of select="$ddb-doc//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style']/text()"/></id>
                    <id type="ddbdp_readable"><xsl:value-of select="$ddb-doc//tei:publicationStmt/tei:idno[@type = 'filename']/text()"/></id>
                    <xsl:for-each select="tokenize($ddb-doc//tei:titleStmt/tei:title/@n, '\s')">
                        <id type="hgv"><xsl:value-of select="."/></id>
                    </xsl:for-each>
                    <xsl:for-each select="$ddb-doc//tei:text/tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-in']">
                        <id type="reprint_in"><xsl:value-of select="string(@n)"/></id>
                    </xsl:for-each>
                    <xsl:for-each select="tokenize($ddb-doc//tei:body/tei:head[@xml:lang='en']/tei:ref[@type='reprint-from']/@n, '\|')">
                        <id type="reprint_from"><xsl:value-of select="."/></id> 
                    </xsl:for-each>
                </xsl:if>
                <!--
                <id type="ddbdp_hybrid" collection="{$col}">
                    <xsl:choose>
                        <xsl:when test="count($ddb-seq) = 2"><xsl:attribute name="item"><xsl:value-of select="$ddb-seq[2]"/></xsl:attribute></xsl:when>
                        <xsl:when test="count($ddb-seq) = 3">
                            <xsl:attribute name="vol"><xsl:value-of select="$ddb-seq[2]"/></xsl:attribute>
                            <xsl:attribute name="item"><xsl:value-of select="$ddb-seq[3]"></xsl:value-of></xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                <xsl:choose>
                    <xsl:when test="count($ddb-seq) = 2"><xsl:value-of select="$col"/>;;<xsl:value-of select="$ddb-seq[2]"/></xsl:when>
                    <xsl:when test="count($ddb-seq) = 3"><xsl:value-of select="$col"/>;<xsl:value-of select="$ddb-seq[2]"/>;<xsl:value-of select="$ddb-seq[3]"/></xsl:when>
                </xsl:choose>
                </id>
                -->
            </xsl:for-each>
        </record>
    </xsl:template>
    
</xsl:stylesheet>
