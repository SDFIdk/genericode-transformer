<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:msg="urn:uuid:74875954-5193-4fb8-ba48-9944e9a36c80"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet that convert a genericode file to a HTML file.
    -->

    <!--
    html-version: see https://www.saxonica.com/documentation12/index.html#!xsl-elements/output and https://www.w3.org/TR/xslt-30/
    include-content-type: meta-tag with Content-Type is not necessary, because <meta charset="utf-8"/> is already present
    omit-xml-declaration: if not present (default: no), https://validator.w3.org will give an error: "XML processing instructions are not supported in HTML"
    -->
    <xsl:output
        method="html"
        html-version="5.0"
        include-content-type="no"
        omit-xml-declaration="yes" />
    
    <!-- See https://www.w3.org/TR/xslt-30/#element-mode and https://www.w3.org/TR/xslt-30/#built-in-templates-shallow-skip -->
    <xsl:mode on-no-match="shallow-skip" />
    
    <xsl:include href="common-html.xsl" />

    <xsl:variable
        name="jQueryVersion"
        select="'3.7.1'" />

    <xsl:variable
        name="dataTablesVersion"
        select="'2.1.8'" />

    <xsl:variable
        name="downloadIcon"
        select="document($designsystemUrl || '/icons/download.svg')" />

    <xsl:variable
        name="licenseByIcon"
        select="document($designsystemUrl || '/icons/license-by.svg')" />

    <xsl:variable
        name="licenseCcIcon"
        select="document($designsystemUrl || '/icons/license-cc.svg')" />

    <xsl:variable
        name="lang"
        select="/gc:CodeList/Annotation/Description/dcterms:language" />

    <xsl:template match="/">
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
                    <xsl:value-of select="gc:CodeList/Identification/ShortName || ' v' || gc:CodeList/Identification/Version" />
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
                <link rel="stylesheet">
                    <xsl:attribute
                        name="href"
                        select="'https://cdn.datatables.net/' || $dataTablesVersion || '/css/dataTables.dataTables.min.css'" />
                </link>
                <script>
                    <xsl:attribute
                        name="src"
                        select="'https://code.jquery.com/jquery-' || $jQueryVersion || '.js'" />
                </script>
                <script>
                    <xsl:attribute
                        name="src"
                        select="'https://cdn.datatables.net/' || $dataTablesVersion || '/js/dataTables.min.js'" />
                </script>
                <script class="init">
                    $(document).ready(function() {
                    $("#codelist").DataTable({
                    "language": {
                    "url":
                    <xsl:call-template name="getLocationDataTablesTranslation" />
                    },
                    "lengthMenu": [
                    [10, 25, 50, -1],
                    [10, 25, 50, "∞"]
                    ]
                    });
                    });
                </script>
                <style>
                    /* Override DataTables color again */
                    div.dt-container .dt-paging .dt-paging-button.disabled, div.dt-container .dt-paging .dt-paging-button.disabled:hover, div.dt-container .dt-paging .dt-paging-button.disabled:active{color: var(--color) !important}
                    div.dt-container .dt-input{color: var(--color);background-color: var(--background-color);}
                    /* Custom styles */
                    #button-backtofrontpage{position: fixed; bottom: var(--space-md); left: var(--space); min-width: 44px; min-height:
                    44px;}
                    #downloadsection a[role="button"]{width: 6rem; margin: var(--space-xs); min-width: 44px;
                    min-height: 44px;}
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
                            <xsl:value-of select="gc:CodeList/Identification/ShortName" />
                        </h1>
                    </div>
                </header>
                <main class="ds-container ds-pt-lg ds-pb-lg"><!-- Use same classes as on other HTML pages -->
                    <div class="ds-grid-2-1">
                        <xsl:apply-templates
                            select="gc:CodeList"
                            mode="metadata" />
                        <xsl:apply-templates
                            select="gc:CodeList"
                            mode="download" />
                    </div>
                    <xsl:apply-templates
                        select="gc:CodeList"
                        mode="data" />
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

    <xsl:template name="getLocationDataTablesTranslation">
        <!-- See https://datatables.net/plug-ins/i18n/ for available translations of DataTables. -->
        <xsl:variable
            name="dataTableslanguages"
            as="map(xsd:string, xsd:string)">
            <xsl:map>
                <xsl:map-entry
                    key="'da'"
                    select="'da'" />
                <xsl:map-entry
                    key="'en'"
                    select="'en-GB'" />
                <!-- Add more as needed -->
            </xsl:map>
        </xsl:variable>
        <xsl:value-of select="'&#34;https://cdn.datatables.net/plug-ins/' || $dataTablesVersion || '/i18n/' || $dataTableslanguages($lang) || '.json&#34;'" />
    </xsl:template>

    <xsl:template
        match="gc:CodeList"
        mode="metadata">
        <section>
            <h2>
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="'metadata'" />
                </xsl:call-template>
            </h2>
            <table>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Identification/ShortName" />
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Identification/Version" />
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Identification/CanonicalUri" />
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Identification/CanonicalVersionUri" />
                </xsl:call-template>
                
                <!-- Different handling of Agency, as it has element children -->
                <tr>
                    <th scope="row">
                        <xsl:call-template name="localizedMessage">
                            <xsl:with-param
                                name="id"
                                select="'agency'" />
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:value-of select="Identification/Agency/LongName" />
                    </td>
                </tr>

                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Annotation/Description/dcterms:provenance" />
                </xsl:call-template>
                <xsl:if test="exists(Annotation/Description/dcterms:source)">
                    <xsl:call-template name="outputHyperlinkMetadataElement">
                        <xsl:with-param
                            name="element"
                            select="Annotation/Description/dcterms:source" />
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Annotation/Description/dcterms:description" />
                </xsl:call-template>
                <xsl:call-template name="outputHyperlinkMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Annotation/Description/dcterms:license" />
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Annotation/Description/dcterms:available" />
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="Annotation/Description/dcterms:publisher" />
                </xsl:call-template>
            </table>
        </section>
    </xsl:template>

    <xsl:template name="outputTextMetadataElement">
        <xsl:param name="element" />
        <tr>
            <th scope="row">
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="lower-case($element/local-name())" />
                </xsl:call-template>
            </th>
            <td>
                <xsl:call-template name="convertNewLineToHtmlLineBreak">
                    <xsl:with-param
                        name="text"
                        select="$element/text()" />
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="outputHyperlinkMetadataElement">
        <xsl:param name="element" />
        <tr>
            <th scope="row">
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="lower-case($element/local-name())" />
                </xsl:call-template>
            </th>
            <td>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$element/text()" />
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$element/local-name() eq 'license'">
                            <xsl:attribute name="target">
                                <xsl:value-of select="'_blank'" />
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'gap: 0;'" /><!-- Put icons closely together -->
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="starts-with($element/text(),'https://creativecommons.org/licenses/by/4.0/')">
                                    <xsl:attribute name="aria-label">
                                <xsl:value-of select="'CC BY 4.0'" />
                            </xsl:attribute>
                                    <xsl:copy-of select="$licenseCcIcon" />
                                    <xsl:copy-of select="$licenseByIcon" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$element/text()" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$element/local-name() eq 'source'">
                            <xsl:value-of select="$element/text()" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$element/text()" />
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </td>
        </tr>
    </xsl:template>

    <xsl:template
        match="gc:CodeList"
        mode="data">
        <section class="ds-pt-lg">
            <h2>
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="'data'" />
                </xsl:call-template>
            </h2>
            <table id="codelist">
                <thead>
                    <tr>
                        <xsl:for-each select="ColumnSet/Column">
                            <th scope="col">
                                <xsl:attribute name="title">
                                    <xsl:value-of select="Annotation/Description/dcterms:description" /> 
                                </xsl:attribute>
                                <xsl:value-of select="@Id" />
                            </th>
                        </xsl:for-each>
                    </tr>
                </thead>
                <tbody>
                    <!-- Assumption: The order of the values is the same as the order of the declared columns and
                    an undefined value is encoded as an empty `Value` element. -->
                    <xsl:for-each select="SimpleCodeList/Row">
                        <tr>
                            <xsl:for-each select="Value">
                                <td>
                                    <xsl:call-template name="convertNewLineToHtmlLineBreak">
                                        <xsl:with-param
                                            name="text"
                                            select="SimpleValue" />
                                    </xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <xsl:template name="convertNewLineToHtmlLineBreak">
        <xsl:param name="text" />
        <xsl:for-each select="tokenize($text, '&#10;')">
            <xsl:value-of select="." />
            <xsl:if test="not(position() eq last())">
                <br />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template
        match="gc:CodeList"
        mode="download">
        <section id="downloadsection">
            <h2>
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="'download'" />
                </xsl:call-template>
            </h2>
            <xsl:call-template name="downloadbutton">
                <xsl:with-param
                    name="downloadlink"
                    select="Identification/LocationUri" />
                <xsl:with-param
                    name="format"
                    select="'GC'" />
                <!-- No entry for genericode in https://www.iana.org/assignments/media-types/media-types.xhtml,
                so using the media type for XML -->
                <xsl:with-param
                    name="mediatype"
                    select="'application/xml'" />
            </xsl:call-template>
            <xsl:for-each select="Identification/AlternateFormatLocationUri[not(@MimeType eq 'text/html')]">
                <xsl:call-template name="downloadbutton">
                    <xsl:with-param
                        name="downloadlink"
                        select="." />
                    <xsl:with-param name="format">
                        <xsl:choose>
                            <xsl:when test="@MimeType eq 'text/csv'">
                                <xsl:value-of select="'CSV'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:value-of select="'WARNING: No format name defined for media type ' || @MimeType" />
                                </xsl:message>
                                <xsl:value-of select="'???'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param
                        name="mediatype"
                        select="@MimeType" />
                </xsl:call-template>
            </xsl:for-each>
        </section>
    </xsl:template>

    <xsl:template name="downloadbutton">
        <xsl:param name="downloadlink" />
        <xsl:param name="format" />
        <xsl:param name="mediatype" />
        <div>
            <a role="button">
                <xsl:attribute name="href">
                    <xsl:value-of select="$downloadlink" />
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="$mediatype" />
                </xsl:attribute>
                <xsl:attribute name="rel">
                    <xsl:value-of select="'alternate'" />
                </xsl:attribute>
                <xsl:copy-of select="$downloadIcon" />
                <xsl:value-of select="$format" />
            </a>
        </div>
    </xsl:template>

</xsl:stylesheet>