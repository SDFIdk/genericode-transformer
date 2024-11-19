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
        select="'8'" /> <!-- designsystem version fra v7.0 til v8 -->

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

    <!-- general struktur for html siden -->
    <xsl:template match="/">
        <html>
            <xsl:attribute
                name="lang"
                select="$lang" />
            <head>
                <!-- dokumentets metadata -->
                <meta charset="UTF-8" /> <!-- sæt html character encoding til utf8 -->
                <meta name="viewport" content="width=device-width, initial-scale=1.0" /> <!-- sæt pænt view for alle devices --> 
                <title>
                    <xsl:value-of select="gc:CodeList/Identification/ShortName" />
                </title>
                <link rel="stylesheet">
                    <xsl:attribute
                        name="href"
                        select="'https://cdn.dataforsyningen.dk/assets/designsystem/v' || $designsystemVersion || '/designsystem.css'" />
                </link>
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
                                "url": <xsl:call-template name="getLocationDataTablesTranslation" />
                            },
                        });
                    });
                </script>
            </head>
            <body>
                <!-- header sektionen -->
                <header class="ds-header">
                    <div class="ds-container">
                        <p class="ds-logo">
                            <div>
                                <!-- AFHÆNGIGHED! linked nedenfor skal mulighvis ændres til en anden afhængighed -->
                                <img src="https://www.klimadatastyrelsen.dk/Media/638615471416374845/logo-ny.svg" alt="Logo" class="svg" width="300" height="360" />
                            </div>
                        </p>
                        <h1>
                            <xsl:value-of select="gc:CodeList/Identification/ShortName" />
                        </h1>
                    </div>
                </header>
                <!-- kerne indholdet for kodelisten -->
                <main class="ds-container ds-pt-lg ds-pb-lg">
                    <section class="ds-grid-2-1">
                        <!-- kodeliste metadata -->
                        <xsl:apply-templates
                            select="gc:CodeList"
                            mode="metadata" />
                        <!-- download kodeliste til ønsket format -->
                        <xsl:call-template name="download" />
                    </section>
                    <!-- kodeliste data! -->
                    <xsl:apply-templates
                        select="gc:CodeList"
                        mode="data" />
                </main>
                <!-- footer sektionen-->
                <xsl:call-template name="footer" />
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
    
    <!-- metadata template -->
    <!-- AFHÆNGIGHED: outputTextMetadataElement, localizedMessage, outputHyperlinkMetadataElement -->
    <xsl:template
        match="gc:CodeList"
        mode="metadata">
        <article>
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
                        select="Annotation/Description/dcterms:available"/>
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param 
                        name="element"
                        select="Annotation/Description/dcterms:provenance"/>
                </xsl:call-template>
                <xsl:call-template name="outputTextMetadataElement">
                    <xsl:with-param 
                        name="element"
                        select="Annotation/Description/dcterms:publisher"/>
                </xsl:call-template>
                <xsl:if test="exists(Annotation/Description/dcterms:source)">
                    <xsl:call-template name="outputTextMetadataElement">
                        <xsl:with-param
                            name="element"
                            select="Annotation/Description/dcterms:source"/>
                    </xsl:call-template>
                </xsl:if>
            </table>
        </article>
    </xsl:template>
    
    <!-- indsætter metadata i tabel -->
    <!-- AFHÆNGIGHED: convertNewLineToHtmlLineBreak, localizedMessage -->
    <!-- bruges af: template gc:codelist/metadata -->
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

    <!-- indsætter hyperlink data i tabel -->
    <!-- AFHÆNGIHED: localizedMessage, licenseicons -->
    <!-- bruges af: template gc:codelist/metadata til license -->
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
                        <xsl:when test="$element/local-name() eq 'license'">
                            <xsl:attribute name="target">
                                <xsl:value-of select="'_blank'" />
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'gap: 0;'" />
                            </xsl:attribute>
                            <!-- indsætter licens iconer -->
                            <xsl:call-template name="licenseicons" />
                        </xsl:when>
                    </xsl:choose>
                </a>
            </td>
        </tr>
    </xsl:template>
    
    <!-- TODO Find out where gc:CodeList/ColumnSet/Column/Annotation/Description/dcterms:description elements
    should be documented -->

    <!-- Template for kodelistens data indhold -->
    <!-- AFHÆNGIGHED: localizedMessage, convertNewLineToHtmlLineBreak -->
    <xsl:template
        match="gc:CodeList"
        mode="data">
        <article class="ds-pt-lg">
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
        </article>
    </xsl:template>

    <!-- html linebreaks -->
    <!-- bruges af: template gc:codelist/metadata, template gc:codelist/data-->
    <xsl:template name="convertNewLineToHtmlLineBreak">
        <xsl:param name="text" />
        <xsl:for-each select="tokenize($text, '&#10;')">
            <xsl:value-of select="." />
            <xsl:if test="not(position() eq last())">
                <br />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- indsætter licens icons -->
    <!-- bruges af: outputHyperlinkMetadataElement -->
    <xsl:template name="licenseicons">
        <svg class="ds-icon" xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" fill="none">
            <g transform="translate(-5.5 3.5)">
                <circle stroke="var(--ds-icon-color, black)" cx="37.7" cy="28.5" r="29"></circle>
                <path fill="var(--ds-icon-color, black)" d="M37.443-3.5c8.988,0,16.57,3.085,22.742,9.257C66.393,11.967,69.5,19.548,69.5,28.5c0,8.991-3.049,16.476-9.145,22.456
                    C53.879,57.319,46.242,60.5,37.443,60.5c-8.649,0-16.153-3.144-22.514-9.43C8.644,44.784,5.5,37.262,5.5,28.5
                    c0-8.761,3.144-16.342,9.429-22.742C21.101-0.415,28.604-3.5,37.443-3.5z M37.557,2.272c-7.276,0-13.428,2.553-18.457,7.657
                    c-5.22,5.334-7.829,11.525-7.829,18.572c0,7.086,2.59,13.22,7.77,18.398c5.181,5.182,11.352,7.771,18.514,7.771
                    c7.123,0,13.334-2.607,18.629-7.828c5.029-4.838,7.543-10.952,7.543-18.343c0-7.276-2.553-13.465-7.656-18.571
                    C50.967,4.824,44.795,2.272,37.557,2.272z M46.129,20.557v13.085h-3.656v15.542h-9.944V33.643h-3.656V20.557
                    c0-0.572,0.2-1.057,0.599-1.457c0.401-0.399,0.887-0.6,1.457-0.6h13.144c0.533,0,1.01,0.2,1.428,0.6
                    C45.918,19.5,46.129,19.986,46.129,20.557z M33.042,12.329c0-3.008,1.485-4.514,4.458-4.514s4.457,1.504,4.457,4.514
                    c0,2.971-1.486,4.457-4.457,4.457S33.042,15.3,33.042,12.329z">
                </path>
            </g>
        </svg>
        <svg class="ds-icon" version="1.0" id="Layer_1" xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" fill="none">
            <g transform="translate(-5.5 3.5)">
                <circle stroke="var(--ds-icon-color, black)" cx="37.785" cy="28.501" r="28.836"></circle>
                <path fill="var(--ds-icon-color, black)" d="M37.441-3.5c8.951,0,16.572,3.125,22.857,9.372c3.008,3.009,5.295,6.448,6.857,10.314
                    c1.561,3.867,2.344,7.971,2.344,12.314c0,4.381-0.773,8.486-2.314,12.313c-1.543,3.828-3.82,7.21-6.828,10.143
                    c-3.123,3.085-6.666,5.448-10.629,7.086c-3.961,1.638-8.057,2.457-12.285,2.457s-8.276-0.808-12.143-2.429
                    c-3.866-1.618-7.333-3.961-10.4-7.027c-3.067-3.066-5.4-6.524-7-10.372S5.5,32.767,5.5,28.5c0-4.229,0.809-8.295,2.428-12.2
                    c1.619-3.905,3.972-7.4,7.057-10.486C21.08-0.394,28.565-3.5,37.441-3.5z M37.557,2.272c-7.314,0-13.467,2.553-18.458,7.657
                    c-2.515,2.553-4.448,5.419-5.8,8.6c-1.354,3.181-2.029,6.505-2.029,9.972c0,3.429,0.675,6.734,2.029,9.913
                    c1.353,3.183,3.285,6.021,5.8,8.516c2.514,2.496,5.351,4.399,8.515,5.715c3.161,1.314,6.476,1.971,9.943,1.971
                    c3.428,0,6.75-0.665,9.973-1.999c3.219-1.335,6.121-3.257,8.713-5.771c4.99-4.876,7.484-10.99,7.484-18.344
                    c0-3.543-0.648-6.895-1.943-10.057c-1.293-3.162-3.18-5.98-5.654-8.458C50.984,4.844,44.795,2.272,37.557,2.272z M37.156,23.187
                    l-4.287,2.229c-0.458-0.951-1.019-1.619-1.685-2c-0.667-0.38-1.286-0.571-1.858-0.571c-2.856,0-4.286,1.885-4.286,5.657
                    c0,1.714,0.362,3.084,1.085,4.113c0.724,1.029,1.791,1.544,3.201,1.544c1.867,0,3.181-0.915,3.944-2.743l3.942,2
                    c-0.838,1.563-2,2.791-3.486,3.686c-1.484,0.896-3.123,1.343-4.914,1.343c-2.857,0-5.163-0.875-6.915-2.629
                    c-1.752-1.752-2.628-4.19-2.628-7.313c0-3.048,0.886-5.466,2.657-7.257c1.771-1.79,4.009-2.686,6.715-2.686
                    C32.604,18.558,35.441,20.101,37.156,23.187z M55.613,23.187l-4.229,2.229c-0.457-0.951-1.02-1.619-1.686-2
                    c-0.668-0.38-1.307-0.571-1.914-0.571c-2.857,0-4.287,1.885-4.287,5.657c0,1.714,0.363,3.084,1.086,4.113
                    c0.723,1.029,1.789,1.544,3.201,1.544c1.865,0,3.18-0.915,3.941-2.743l4,2c-0.875,1.563-2.057,2.791-3.541,3.686
                    c-1.486,0.896-3.105,1.343-4.857,1.343c-2.896,0-5.209-0.875-6.941-2.629c-1.736-1.752-2.602-4.19-2.602-7.313
                    c0-3.048,0.885-5.466,2.658-7.257c1.77-1.79,4.008-2.686,6.713-2.686C51.117,18.558,53.938,20.101,55.613,23.187z">
                </path>
            </g>
        </svg>
    </xsl:template>
    <!-- opstilling af download delen -->
    <!-- AFHÆNGIG: downloadbutton -->
    <!-- bruges af: root template i body/main -->
    <xsl:template name="download">
        <article>
            <h2>Download</h2>
            <div>
                <!-- download format genericode -->
                <xsl:call-template name="downloadbutton">
                    <xsl:with-param name="downloadlink" select="gc:CodeList/Identification/LocationUri" />
                    <xsl:with-param name="format" select="'GC'" />
                </xsl:call-template>
            </div>
            <div>
                <!-- download format CSV -->
                <xsl:for-each select="gc:CodeList/Identification/AlternateFormatLocationUri[not(@MimeType eq 'text/html')]">
                    <xsl:call-template name="downloadbutton">
                        <xsl:with-param name="downloadlink" select="." />
                        <xsl:with-param name="format" select="'CSV'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </div>
        </article>
    </xsl:template>

    <!-- styling af download knappen og hyperlink -->
    <!-- bruges af: download -->
    <xsl:template name="downloadbutton">
        <xsl:param name="downloadlink"/>
        <xsl:param name="format" />
        <!-- element størrelse, afstand til ovenliggende element, angiv element som knap -->
        <a style="width: 5rem; margin-top: 10px;" role="button">
            <xsl:attribute name="href">
                <xsl:value-of select="$downloadlink" />
            </xsl:attribute>
            <svg class="ds-icon" width="29" height="29" viewBox="0 0 29 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g stroke="var(--ds-icon-color, white)" stroke-linejoin="round" stroke-linecap="round" stroke-width="var(--ds-icon-stroke, 1)">
                    <path d="M27 8L15.21 19.79C14.82 20.18 14.18 20.18 13.79 19.79L2 8M14.5 20L14.5 1M1.5 26.5H27.5"></path>
                </g>
            </svg><xsl:value-of select="$format" />
        </a>
    </xsl:template>

    <!-- footer opsætning -->
    <!-- bruges af: root template sidst i body-->
    <xsl:template name="footer">
        <footer class="ds-footer" data-theme="light">
            <div class="ds-container">
                <h2 class="ds-logo-responsive ds-logo-pull-left">
                    <span>Klimadatastyrelsen</span>
                </h2>
                <a href="mailto:kodeliste@kds.dk?subject=Angående%20kodeliste" target="_blank">Send en e-mail til os for henvendelser om kodelister</a>
                <hr />
                <p>2024-11-08, version 1.0.0</p>
            </div>
            <aside class="ds-container">
                <code-example data-snip="ex-layout"/>
            </aside>
            <!-- fix knap til bundens venstre side som bringer bruger tilbage til kodelisteregister-->
            <a style="position: fixed; bottom: var(--space-md); left: var(--space);" role="button" href="https://sdfidk.github.io/kodelisteregister">
                <svg class="ds-icon" width="29" height="29" viewBox="0 0 29 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g stroke="var(--ds-icon-color, white)" stroke-linejoin="round" stroke-linecap="round" stroke-width="var(--ds-icon-stroke, 1)">
                        <path d="M15.54 27.54L3.75 15.75C3.36 15.36 3.36 14.73 3.75 14.34L15.54 2.54M3.54 15.04H25.54"></path>
                    </g>
                </svg>Tilbage til register
            </a>
        </footer>
    </xsl:template>

</xsl:stylesheet>