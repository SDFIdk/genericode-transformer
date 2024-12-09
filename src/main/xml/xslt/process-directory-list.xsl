<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
    Stylesheet that processes the result of an XProc p:directory-list step,
    executed on a folder containing the HTML versions of a code list,
    so that c:file elements are sorted on version, descending.
    -->

    <!-- Identity transformation -->
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:include href="version-regex-variable.xsl" />

    <xsl:template match="c:directory[exists(c:file)]">
        <c:directory>
            <xsl:apply-templates select="@*" />
            <!-- Sort files on their version number, which is present in the file name -->
            <xsl:for-each select="c:file">
                <!-- first sort descending on the major part of the version -->
                <xsl:sort
                    select="replace(@name, $regexNameWithVersion, '$2')"
                    data-type="number"
                    order="descending" />
                <!-- then sort descending on the minor part of the version -->
                <xsl:sort
                    select="replace(@name, $regexNameWithVersion, '$3')"
                    data-type="number"
                    order="descending" />
                <!-- finally, sort descending on the patch part of the version -->
                <xsl:sort
                    select="replace(@name, $regexNameWithVersion, '$4')"
                    data-type="number"
                    order="descending" />
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </c:directory>
    </xsl:template>

</xsl:stylesheet>