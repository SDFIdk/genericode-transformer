<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                exclude-result-prefixes="c">
    <xsl:output method="xml"
                encoding="UTF-8"
                indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:include href="version-regex-variable.xsl"/>
    <xsl:template match="/c:directory/c:directory/c:directory">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="c:directory"/>
            <xsl:for-each select="c:file">
                <!-- Sort files on version in descending order;
                the file containing the latest version will be the first in the sequence. -->
                <xsl:sort select="replace(@name, $regexNameWithVersion, '$2')"
                          data-type="number"
                          order="descending"/>
                <!-- then sort descending on the minor part of the version -->
                <xsl:sort select="replace(@name, $regexNameWithVersion, '$3')"
                          data-type="number"
                          order="descending"/>
                <!-- finally, sort descending on the patch part of the version -->
                <xsl:sort select="replace(@name, $regexNameWithVersion, '$4')"
                          data-type="number"
                          order="descending"/>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>