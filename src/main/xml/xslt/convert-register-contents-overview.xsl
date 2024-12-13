<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet that converts an XHTML page describing the main register or a subregister
    created by AsciiDoctor to an HTML page with styling, the common footer, etc.
    Assumption: the HTML page to be transformed was created using the following CLI options:
    -b xhtml5 -a stylesheet!
    -->

    <xsl:output
        method="html"
        html-version="5.0"
        include-content-type="no"
        omit-xml-declaration="yes" />

    <xsl:mode on-no-match="shallow-copy" />

    <xsl:include href="common-html.xsl" />
    
    <!--
    1: Top level register
    2: 2nd level register
    -->
    <xsl:param
        name="level"
        required="true"
        as="xsd:integer" />
    
    <!-- Set required to false for easier testing of this stylesheet -->
    <xsl:param
        name="registerContentsElement"
        required="false" />

    <xsl:variable
        name="lang"
        select="/xhtml:html/@lang" />

    <xsl:template match="xhtml:head">
        <xsl:copy>
            <xsl:apply-templates select="*" />
            <link rel="stylesheet">
                <xsl:attribute
                    name="href"
                    select="$designsystemUrl || '/designsystem.css'" />
            </link>
            <script type="module">
                import {
                DSLogo,
                DSLogoTitle
                } from
                <xsl:value-of select="' '' ' || $designsystemUrl || '/designsystem.js '' '" />
                customElements.define('ds-logo', DSLogo)
                customElements.define('ds-logo-title', DSLogoTitle)
            </script>
            <style>
                /* Custom styles */
                #button-backtofrontpage{position: fixed; bottom: var(--space-md); left: var(--space); min-width: 44px; min-height: 44px;}
                /* No extra top margin for the top level sections */
                section + section, section section {margin-top: var(--space-md)}
                .warning *{color: var(--warning);font-weight: 500}
            </style>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xhtml:div[@id='header']">
        <header class="ds-header">
            <div class="ds-container">
                <xsl:call-template name="generateDsLogoTitle" />
                <xsl:copy-of select="xhtml:h1" />
                <p class="manchet">
                    <!-- Preamble = content between the end of the document header and the first section title in the document body,
                    see https://docs.asciidoctor.org/asciidoc/latest/blocks/preamble-and-lead/ -->
                    <xsl:apply-templates select="//xhtml:div[@id eq 'preamble']" />
                </p>
            </div>
        </header>
    </xsl:template>

    <xsl:template match="xhtml:div[@id='content']">
        <main class="ds-container ds-pt-lg ds-pb-lg">
            <div class="ds-grid-1-2">
                <section>
                    <h2>
                        <xsl:choose>
                            <xsl:when test="$level eq 1">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'subregisters'" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$level eq 2">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'codelists'" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:value-of select="'WARNING: Unknown level ' || $level" />
                                </xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </h2>
                    <xsl:if test="exists($registerContentsElement)">
                        <xsl:copy-of select="$registerContentsElement" />
                    </xsl:if>
                </section>
                <div>
                    <!-- Preamble is taken care of in the header -->
                    <xsl:apply-templates select="xhtml:*[not(@id eq 'preamble')]" />
                </div>
            </div>
        </main>
        <xsl:if test="$level eq 2">
            <div class="ds-padding">
                <nav>
                    <a
                        id="button-backtofrontpage"
                        href="../index.html"
                        role="button">
                        <xsl:copy-of select="$arrowLeftIcon" />
                        <xsl:call-template name="localizedMessage">
                            <xsl:with-param
                                name="id"
                                select="'backtofrontpage'" />
                        </xsl:call-template>
                    </a>
                </nav>
            </div>
        </xsl:if>
        <xsl:call-template name="generateHtmlFooter" />
    </xsl:template>
    
    <!-- Sections of different levels,
    see https://docs.asciidoctor.org/asciidoc/latest/sections/titles-and-levels/,
    are represented by a div element with class sect1, sect2, etc. in the XHTML generated by AsciiDoctor -->
    <xsl:template match="xhtml:div[matches(@class, 'sect\d')]">
        <section>
            <xsl:apply-templates select="node()" />
        </section>
    </xsl:template>

    <!-- Configure absolute HTTP(s) URIs to open in a new tab / window.
    (links within the register are relative links) -->
    <xsl:template match="xhtml:a">
        <xsl:copy>
            <xsl:if test="matches(@href, 'https?://.*') or matches(@href, 'mailto:.*')">
                <!-- This will simply override the attributes
                if they already exist -->
                <xsl:attribute
                    name="target"
                    select="'_blank'" />
                <xsl:attribute
                    name="rel"
                    select="'noreferrer noopener'" /><!-- See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#security_and_privacy -->
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
            <xsl:choose>
                <xsl:when test="matches(@href, 'https?://.*')">
                    <xsl:copy-of select="$exitSiteIcon" />
                </xsl:when>
                <xsl:when test="matches(@href, 'mailto:.*')">
                    <xsl:copy-of select="$mailIcon" />
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>