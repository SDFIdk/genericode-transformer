<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheets that sort the rows of a one column table 
    on their contents.
    It is assumed that the HTML table has an HTML tbody child.
    -->

    <xsl:output
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="yes" />

    <xsl:mode on-no-match="shallow-copy" />

    <xsl:template match="xhtml:tbody">
        <xsl:copy>
            <xsl:for-each select="xhtml:tr">
                <xsl:sort
                    select="xhtml:td"
                    data-type="text"
                    order="ascending" />
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" />
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>