<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">

    <xsl:output
        indent="yes"
        omit-xml-declaration="yes" />

    <xsl:mode on-no-match="shallow-skip" />

    <xsl:include href="version-regex-variable.xsl" />

    <xsl:include href="common-l10n.xsl" />

    <xsl:param
        name="lang"
        required="true" />

    <xsl:template match="/c:directory">
        <table>
            <tbody>
                <xsl:for-each select="c:directory">
                    <xsl:sort
                        select="@name"
                        data-type="text"
                        order="ascending" />
                    <tr>
                        <td>
                            <xsl:value-of select="@name" />
                        </td>
                        <td>
                            <a>
                                <xsl:attribute
                                    name="href"
                                    select="let $regex := '^v(([0-9]+)\.([0-9]+)\.([0-9]+))\..*',
                                        $files := c:file[not(@name eq 'index.html')],
                                        $filesSortedOnVersionAscending := sort(
                                          $files,
                                          default-collation(),
                                          function($file) {
                                            (
                                              number(replace($file/@name, $regex, '$2')),
                                              number(replace($file/@name, $regex, '$3')),
                                              number(replace($file/@name, $regex, '$4'))
                                            )
                                          }
                                        )
                                        return './' || @name || '/' || $filesSortedOnVersionAscending[last()]/@name" />
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'latestversion'" />
                                </xsl:call-template>
                            </a>
                        </td>
                        <td>
                            <a>
                                <xsl:attribute
                                    name="href"
                                    select="'./' || @name || '/index.html'" />
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'allversions'" />
                                </xsl:call-template>
                            </a>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>