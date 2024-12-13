<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    name="update-subregister-front-pages"
    type="gt:update-subregister-front-pages"
    version="3.0">

    <p:documentation>This step takes a directory containing directories,
        and updates the overview file index.html in each subdirectory:
        * an overview of the code lists present is added (based on the directory structure);
        * styling is added.
        It is assumed that
        * the top level directory represent the code list register overall;
        * the second level directories represent subregisters containing code lists;
        * index.html files have been generated already in the subdirectories before calling this step (e.g. by AsciiDoctorj)
    </p:documentation>

    <p:option name="input-directory" />

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:variable
        name="input-directory-urified"
        select="p:urify($input-directory)" />

    <p:directory-list
        name="create-directory-list"
        message="Create directory list for {$input-directory}">
        <p:with-option
            name="path"
            select="$input-directory-urified" />
        <p:with-option
            name="include-filter"
            select="'.*\.html'" />
        <p:with-option
            name="max-depth"
            select="'3'" />
    </p:directory-list>

    <p:store
        name="store-directory-list"
        message="Store processed directory list for debugging"
        href="{'../../../../target/store-directory-list-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:for-each>
        <p:with-input select="/c:directory/c:directory" />

        <p:identity name="for-each-input" />

        <p:store
            name="store-for-each-input"
            message="Store for each input for debugging"
            href="{'../../../../target/store-for-each-input-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
            serialization="map { 'indent': true() }"
            use-when="$debug">
        </p:store>

        <!-- directory-uri will be absolute (cannot be seen in the debug files stored in the debug step above) -->
        <p:variable
            name="directory-uri"
            select="base-uri(/c:directory)" />

        <p:variable
            name="overview-file-uri"
            select="base-uri(/c:directory/c:file[@name eq 'index.html'])" />

        <p:load
            name="load-index-html"
            message="Load {$overview-file-uri}"
            href="{$overview-file-uri}" />

        <p:variable
            name="lang"
            select="/xhtml:html/@lang" />

        <p:xslt
            name="convert-code-list-directory-to-html-element"
            message="Create HTML element from file names in {$directory-uri}">
            <p:with-input port="source">
                <p:pipe
                    step="for-each-input"
                    port="result" />
            </p:with-input>
            <p:with-input
                port="stylesheet"
                href="../xslt/convert-code-list-directory-to-html-element.xsl" />
            <p:with-option
                name="parameters"
                select="map {'lang' : $lang }" />
        </p:xslt>

        <p:store
            name="store-html-element"
            message="Store HTML list for debugging"
            href="{'../../../../target/store-html-element-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
            serialization="map { 'indent': true() }"
            use-when="$debug">
        </p:store>

        <p:variable
            name="html-element"
            select="/" />

        <p:xslt
            name="transform-code-list-overview-page"
            message="Update code list version overview page">
            <p:with-input port="source">
                <p:pipe
                    step="load-index-html"
                    port="result" />
            </p:with-input>
            <p:with-input
                port="stylesheet"
                href="../xslt/convert-register-contents-overview.xsl" />
            <p:with-option
                name="parameters"
                select="map {'level' : 2, 'registerContentsElement' : $html-element }" />
        </p:xslt>

        <!-- Note: opposed to the other p:store steps, this step is part of the production flow,
        it's purpose is not debugging.
        The original overview file is overwritten. -->
        <p:store
            name="store-overview-file"
            message="Overwrite overview file in {$overview-file-uri}"
            href="{$overview-file-uri}" />
    </p:for-each>

</p:declare-step>