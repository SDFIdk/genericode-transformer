<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet that converts the result of an XProc p:directory-list step,
    executed on a folder containing the HTML versions of a code list,
    to an HTML table.
    
    See the documentation of p:directory-list for more information about the input structure,
    and see also an example in the XSpec test for this stylesheet.
    -->

    <xsl:output
        indent="yes"
        omit-xml-declaration="yes" />

    <xsl:mode on-no-match="shallow-skip" />

    <xsl:include href="version-regex-variable.xsl" />

    <xsl:template match="/c:directory">
        <table>
            <tbody>
                <xsl:for-each select="c:file">
                    <tr>
                        <td>
                            <a>
                                <xsl:attribute
                                    name="href"
                                    select="'./' || @name" />
                                <xsl:value-of select="replace(@name, $regexNameWithVersion, '$1')" />
                            </a>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>