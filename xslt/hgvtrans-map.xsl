<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="/tei:TEI">
        <record>
            <id type="hgv_trans"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'filename']/text()"/></id>
            <id type="ddbdp_hybrid" collection="{substring-before(//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style'], ';')}" 
                vol="{substring-before(substring-after(//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style'],';'), ';')}"
                item="{substring-after(substring-after(//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style'],';'),';')}"><xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'ddb-perseus-style']/text()"/></id>
        </record>
    </xsl:template>
</xsl:stylesheet>
