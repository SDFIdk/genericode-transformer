<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:msg="urn:uuid:74875954-5193-4fb8-ba48-9944e9a36c80"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="gc xsd dcterms msg">

    <!--
    html-version: see https://www.saxonica.com/documentation12/index.html#!xsl-elements/output and https://www.w3.org/TR/xslt-30/
    include-content-type: meta-tag with Content-Type is not necessary, because <meta charset="utf-8"/> is already present
    omit-xml-declaration: if not present (default: no), https://validator.w3.org will give an error: "XML processing instructions are not supported in HTML"
    -->
    <xsl:output
        method="xhtml"
        html-version="5.0"
        include-content-type="no"
        omit-xml-declaration="yes"
        indent="yes" />
    
    <!-- See https://www.w3.org/TR/xslt-30/#element-mode and https://www.w3.org/TR/xslt-30/#built-in-templates-shallow-skip -->
    <xsl:mode on-no-match="shallow-skip" />

    <xsl:param
        name="jQueryVersion"
        select="'3.7.1'" />

    <xsl:param
        name="dataTablesVersion"
        select="'2.1.8'" />

    <xsl:param
        name="designsystemVersion"
        select="'7.0'" />

    <xsl:variable
        name="lang"
        select="/gc:CodeList/Annotation/Description/dcterms:language" />

    <xsl:variable
        name="localizedMessages"
        select="document(concat('../../resources/locale/', $lang, '.xml'))/msg:messages" />

    <xsl:template name="localizedMessage">
        <xsl:param name="id" />
        <xsl:choose>
            <xsl:when test="exists($localizedMessages/msg:message[@id=$id])">
                <xsl:value-of select="string($localizedMessages/msg:message[@id=$id])" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:value-of select="'WARNING: No message with id &#34;' || $id || '&#34; is defined for language ' || $lang || '.'" />
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/">
        <html>
            <xsl:attribute
                name="lang"
                select="$lang" />
            <head>
                <title>
                    <xsl:value-of select="gc:CodeList/Identification/ShortName" />
                </title>
                <link rel="stylesheet">
                    <xsl:attribute
                        name="href"
                        select="'https://cdn.dataforsyningen.dk/assets/designsystem/v' || $designsystemVersion || '/designsystem.css'" />
                    <link rel="stylesheet">
                        <xsl:attribute
                            name="href"
                            select="'https://cdn.datatables.net/' || $dataTablesVersion || '/css/dataTables.dataTables.min.css'" />
                    </link>
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
                                "url": <xsl:call-template name="getLocationDataTablesTranslation" />
                            },
                        });
                    });
                </script>
            </head>
            <body>
                <header>
                    <h1>
                        <xsl:value-of select="gc:CodeList/Identification/ShortName" />
                    </h1>
                </header>
                <main>
                    <xsl:apply-templates
                        select="gc:CodeList"
                        mode="metadata" />
                    <xsl:apply-templates
                        select="gc:CodeList"
                        mode="data" />
                </main>
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
        <h2>
            <xsl:call-template name="localizedMessage">
                <xsl:with-param
                    name="id"
                    select="'metadata'" />
            </xsl:call-template>
        </h2>
        <table>
            <!-- TODO Agree on order of elements -->

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
            <!-- TODO add other Identification/* elements -->
            
            <!--  TODO Move download links in their own section? With a nice button perhaps? -->
            <xsl:call-template name="outputHyperlinkMetadataElement">
                <xsl:with-param
                    name="element"
                    select="Identification/LocationUri" />
            </xsl:call-template>
            <xsl:for-each select="Identification/AlternateFormatLocationUri[not(@MimeType eq 'text/html')]">
                <xsl:call-template name="outputHyperlinkMetadataElement">
                    <xsl:with-param
                        name="element"
                        select="." />
                </xsl:call-template>
            </xsl:for-each>
            
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
                    select="Annotation/Description/dcterms:description" />
            </xsl:call-template>
            <xsl:call-template name="outputHyperlinkMetadataElement">
                <xsl:with-param
                    name="element"
                    select="Annotation/Description/dcterms:license" />
            </xsl:call-template>
            <!-- TODO Add other Dublin Core elements -->
        </table>
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
                        <xsl:when test="$element/local-name() eq 'LocationUri'">
                            <xsl:attribute name="type">
                                <xsl:value-of select="'application/xml'" />
	                       </xsl:attribute>
                            <xsl:attribute name="rel">
                                <xsl:value-of select="'alternate'" />
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$element/local-name() eq 'AlternateFormatLocationUri'">
                            <xsl:attribute name="type">
                                <xsl:value-of select="@MimeType" />
	                       </xsl:attribute>
                            <xsl:attribute name="rel">
                                <xsl:value-of select="'alternate'" />
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="$element/text()" />
                </a>
            </td>
        </tr>
    </xsl:template>
    
    <!-- TODO Find out where gc:CodeList/ColumnSet/Column/Annotation/Description/dcterms:description elements
    should be documented -->

    <xsl:template
        match="gc:CodeList"
        mode="data">
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
                                    <xsl:with-param name="text" select="SimpleValue" />
                                </xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
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
    
</xsl:stylesheet>