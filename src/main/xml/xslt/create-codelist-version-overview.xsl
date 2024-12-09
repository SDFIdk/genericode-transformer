<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet that create an HTML overview page for the versions that exist
    for a code list.
    -->

    <xsl:output
        method="html"
        html-version="5.0"
        include-content-type="no"
        omit-xml-declaration="yes" />

    <xsl:mode on-no-match="shallow-skip" />

    <xsl:include href="common-html.xsl" />

    <xsl:param
        name="lang"
        required="true" />

    <xsl:param
        name="codeListName"
        required="true" />

    <!-- Set required to false for easier testing of this stylesheet -->
    <xsl:param
        name="versionElement"
        required="false" />
        
    <!-- Invoke this template to use this stylesheet -->
    <xsl:template name="start-template">
        <html>
            <xsl:attribute
                name="lang"
                select="$lang" />
            <head>
                <meta charset="utf-8" /><!-- See https://html.spec.whatwg.org/multipage/semantics.html#charset -->
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0" /><!-- Nice view, also for narrow screen devices, see https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag -->
                <title>
                    <xsl:value-of select="$codeListName" />
                </title>
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
                </style>
            </head>
            <body>
                <header class="ds-header">
                    <div class="ds-container">
                        <ds-logo-title>
                            <xsl:attribute name="title">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                name="id"
                                select="'registername'" />
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:attribute name="byline">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                name="id"
                                select="'registerowner'" />
                                </xsl:call-template>
                            </xsl:attribute>
                        </ds-logo-title>
                        <h1>
                            <xsl:value-of select="$codeListName" />
                        </h1>
                        <p class="manchet">
                            <xsl:call-template name="localizedMessage">
                                <xsl:with-param
                                    name="id"
                                    select="'codelistoverviewmanchet1'" />
                            </xsl:call-template>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$codeListName" />
                            <xsl:text>.</xsl:text>
                        </p>
                    </div>
                </header>
                <main class="ds-container ds-pt-lg ds-pb-lg"><!-- Use same classes as on other HTML pages -->
                    <div class="ds-grid-1-2">
                        <section>
                            <h2 id="versions">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'chooseversion'" />
                                </xsl:call-template>
                            </h2>
                            <xsl:if test="exists($versionElement)">
                                <xsl:copy-of select="$versionElement" />
                            </xsl:if>
                        </section>
                        <section>
                            <h2>
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'aboutversions'" />
                                </xsl:call-template>
                            </h2>
                            <p>
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                                        name="id"
                                        select="'readaboutversions'" />
                                </xsl:call-template>
                                <xsl:text>&#32;</xsl:text>
                                <a href="../../index.html">
                                    <xsl:call-template name="localizedMessage">
                                        <xsl:with-param
                                            name="id"
                                            select="'frontpage'" />
                                    </xsl:call-template>
                                </a>
                                .
                            </p>
                        </section>
                    </div>
                </main>
                <div class="ds-padding">
                    <nav>
                        <a
                            id="button-backtofrontpage"
                            href="../../index.html"
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
                <xsl:call-template name="generateHtmlFooter" />
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>