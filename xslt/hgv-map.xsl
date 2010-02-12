<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="/tei:TEI">
        <xsl:variable name="bibl" select="//tei:div[@type='bibliography']//tei:bibl[@type='publication' and @subtype='principal']"/>
        <record>
            <id type="ddbdp_hybrid" collection="{substring-before(//tei:publicationStmt/tei:idno[@type='ddb-hybrid'], ';')}" 
                vol="{substring-before(substring-after(//tei:publicationStmt/tei:idno[@type='ddb-hybrid'],';'), ';')}"
                item="{substring-after(substring-after(//tei:publicationStmt/tei:idno[@type='ddb-hybrid'],';'),';')}"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type='ddb-hybrid']"/></id>
            <id type="ddbdp_perseus"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type='ddb-perseus-style']"/></id>
            <id type="tm"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type='TM']"/></id>
            <id type="hgv"><xsl:attribute name="collection">
                    <xsl:value-of select="$bibl/tei:title[@level='s']"/>
                </xsl:attribute>
                <xsl:if test="$bibl//tei:biblScope[@type='volume']">
                    <xsl:attribute name="volume"><xsl:value-of select="$bibl//tei:biblScope[@type='volume']"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$bibl//tei:biblScope[@type='numbers']">
                    <xsl:attribute name="item"><xsl:value-of select="$bibl//tei:biblScope[@type='numbers']"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$bibl//tei:biblScope[@type='parts']">
                    <xsl:attribute name="item"><xsl:value-of select="$bibl//tei:biblScope[@type='parts']"/></xsl:attribute>
                </xsl:if>
            <xsl:value-of select="//tei:publicationStmt/tei:idno[@type='HGV']"/></id>
            <xsl:for-each select="//tei:text/tei:body//tei:bibl[@type='publication'][@subtype='other']">
                <id type="anderePubl"><xsl:value-of select="."/></id>
            </xsl:for-each>
            <xsl:for-each select="//tei:text/tei:body/tei:div[@type='figure']//tei:graphic[starts-with(@url, 'http://wwwapp.cc.columbia.edu')]">
                <id type="apis"><xsl:value-of select="substring-after(@url, 'key=')"/></id>
            </xsl:for-each>
        </record>
    </xsl:template>
</xsl:stylesheet>
