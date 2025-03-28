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

    <!-- Do not match atom:entry/atom:updated! -->
    <xsl:template match="atom:feed/atom:updated">
        <xsl:copy>
            <xsl:value-of select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xsd:dayTimeDuration('PT0S')), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z00:00t]')" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>