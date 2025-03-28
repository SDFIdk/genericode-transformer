<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/2005/Atom"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output indent="yes" />
    
    <!-- Identity transformation -->
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:template match="atom:feed">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="node()[not(node-name() eq QName('http://www.w3.org/2005/Atom', 'atom:entry'))]" />
            <xsl:apply-templates select="atom:entry">
                <xsl:sort
                    select="xsd:dateTime(atom:updated)"
                    order="descending" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>