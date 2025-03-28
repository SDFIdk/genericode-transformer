<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/2005/Atom"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xhtml xsd">
    
    <!-- 
    Stylesheet that creates an Atom Feed Document containing only metadata.
    -->

    <xsl:output indent="yes" />

    <xsl:mode on-no-match="shallow-skip" />
    
    <xsl:include href="common-l10n.xsl" />
        
    <!-- URI representing the directory in which the overview file and the feed will be published. -->
    <xsl:param
        name="codeListSubregisterUri"
        required="true" />

    <xsl:param
        name="overviewFileName"
        as="xsd:string"
        required="false"
        select="'index.html'" />

    <xsl:param
        name="feedFileName"
        as="xsd:string"
        required="false"
        select="'feed.atom'" />
        
    <xsl:param
        name="updatedFormattedDateTime"
        select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xsd:dayTimeDuration('PT0S')), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z00:00t]')"
        as="xsd:string" />
        
    <xsl:variable
        name="lang"
        select="/xhtml:html/@lang" />
        
    <!-- This template checks whether certain metadata elements are present 
    and have a value set by a built-in or custom attribute in the original AsciiDoc files.
    See also https://docs.asciidoctor.org/asciidoc/latest/document/metadata/ and src/main/xml/xhtml/docinfo.html. -->
    <xsl:template match="/xhtml:html/xhtml:head">
        <xsl:document>
	       <feed>
                <link
                    rel="self"
                    type="application/atom+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$codeListSubregisterUri || $feedFileName" />
                    </xsl:attribute>
                </link>
                <link
                    rel="alternate"
                    type="text/html">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$codeListSubregisterUri || $overviewFileName" />
                    </xsl:attribute>
                </link>
                <!-- Add name of the main register in front of the name of the subregister to give some context,
                as feeds are used in a feed reader, and hence outside the context of the code list register. -->
                <title>
                    <xsl:call-template name="localizedMessage">
                        <xsl:with-param
                            name="id"
                            select="'registername'" />
                    </xsl:call-template>
                    <xsl:value-of select="' - '" />
                    <xsl:value-of select="xhtml:title" />
                </title>
                <!-- Use xsl:if to avoid empty elements.
                Atom feed validation will fail if no id present all, but not if the id is empty.
                If the metadata element has been added by using src/main/xml/xhtml/docinfo.html, but
                the attribute was not actually set in the original AsciiDoc file, it will be e.g.
                content={identifier}
                hence the check for starting with {. -->
                <xsl:if test="exists(xhtml:meta[@name='DC.identifier']/@content) and not(starts-with(xhtml:meta[@name='DC.identifier']/@content, '{'))">
                    <id>
                        <xsl:value-of select="xhtml:meta[@name='DC.identifier']/@content" />
                    </id>
                </xsl:if>
                <xsl:if test="(exists(xhtml:meta[@name='author']/@content) and not(starts-with(xhtml:meta[@name='author']/@content, '{'))) or (exists(xhtml:meta[@name='email']/@content) and not(starts-with(xhtml:meta[@name='email']/@content, '{')))">
                    <author>
                        <xsl:if test="exists(xhtml:meta[@name='author']/@content) and not(starts-with(xhtml:meta[@name='author']/@content, '{'))">
                            <name>
                                <xsl:value-of select="xhtml:meta[@name='author']/@content" />
                            </name>
                        </xsl:if>
                        <xsl:if test="exists(xhtml:meta[@name='email']/@content) and not(starts-with(xhtml:meta[@name='email']/@content, '{'))">
                            <email>
                                <xsl:value-of select="xhtml:meta[@name='email']/@content" />
                            </email>
                        </xsl:if>
                    </author>
                </xsl:if>
                <updated>
                    <xsl:value-of
                        select="$updatedFormattedDateTime" />
                </updated>
            </feed>
        </xsl:document>
    </xsl:template>

</xsl:stylesheet>