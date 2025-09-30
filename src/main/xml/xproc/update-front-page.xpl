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
    name="update-front-page"
    type="gt:update-front-page"
    version="3.1">

    <p:documentation>This step takes a directory containing an overview file index.html,
        and updates that file:
        * an overview of the subregisters present is added (based on the directory structure and the title of index.html of the subregister);
        * styling is added.
        
        It is assumed that
        * the top level directory represent the code list register overall;
        * the second level directories represent subregisters;
        * an index.html file has been generated already in the top level directory before calling this step (e.g. by AsciiDoctor).
        
        This step has neither input nor output ports. It reads from and writes to a file system.
    </p:documentation>
    
    <p:import href="directory-list-absolute-uris.xpl" />

    <p:option
        name="input-directory"
        required="true" />

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:variable
        name="input-directory-urified"
        select="p:urify($input-directory)" />

    <gt:directory-list-absolute-uris
        name="create-directory-list"
        p:message="Produce list of contents of {$input-directory}">
        <p:with-option
            name="path"
            select="$input-directory-urified" />
        <p:with-option
            name="include-filter"
            select="'.*\.html'" />
        <p:with-option
            name="max-depth"
            select="'2'" />
    </gt:directory-list-absolute-uris>

    <p:store
        name="store-directory-list"
        message="Store processed directory list for debugging"
        href="{'../../../../target/store-directory-list-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:variable
        name="overview-file-uri"
        select="base-uri(/c:directory/c:file[@name eq 'index.html'])" />

    <p:for-each>
        <p:with-input select="/c:directory/c:directory" />

        <p:variable
            name="subregister-overview-file-relative-uri-string"
            select="'./' || /c:directory/@name || '/index.html'" />

        <p:variable
            name="subregister-overview-file-absolute-uri"
            select="base-uri(/c:directory/c:file[@name eq 'index.html'])" />

        <p:load
            name="load-subregister-index-html"
            message="Load {$subregister-overview-file-absolute-uri}"
            href="{$subregister-overview-file-absolute-uri}" />

        <p:variable
            name="title"
            select="/xhtml:html/xhtml:head/xhtml:title/text()" />

        <p:identity message="Create table row for {$title}">
            <p:with-input port="source">
                <p:inline exclude-inline-prefixes="#all">
                    <tr xmlns="http://www.w3.org/1999/xhtml">
                        <td>
                            <a href="{$subregister-overview-file-relative-uri-string}">
                                {$title}
                            </a>
                        </td>
                    </tr>
                </p:inline>
            </p:with-input>
        </p:identity>
    </p:for-each>

    <p:wrap-sequence
        name="wrap-subregisters"
        message="Wrap the links and titles of the subregisters to one element">
        <p:with-option
            name="wrapper"
            select="QName('http://www.w3.org/1999/xhtml', 'tbody')" />
    </p:wrap-sequence>

    <p:store
        name="store-for-each-output"
        message="Store for each output for debugging"
        href="{'../../../../target/store-for-each-output-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:wrap>
        <p:with-option
            name="match"
            select="'xhtml:tbody'" />
        <p:with-option
            name="wrapper"
            select="QName('http://www.w3.org/1999/xhtml', 'table')" />
    </p:wrap>

    <p:xslt
        name="sort-on-name"
        message="Sort rows on name"
        version="3.0">
        <p:with-input
            port="stylesheet"
            href="../xslt/sort-one-column-table-on-contents.xsl" />
    </p:xslt>

    <p:variable
        name="html-element"
        select="/xhtml:table" />

    <p:load
        name="load-index-html"
        message="Load {$overview-file-uri}"
        href="{$overview-file-uri}" />

    <p:xslt
        name="transform-front-page"
        message="Update front page"
        version="3.0">
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
            select="map {'level' : 1, 'registerContentsElement' : $html-element}" />
    </p:xslt>

    <!-- Note: opposed to the other p:store steps, this step is part of the production flow,
    it's purpose is not debugging.
    The original overview file is overwritten. -->
    <p:store
        name="store-overview-file"
        message="Overwrite overview file in {$overview-file-uri}"
        href="{$overview-file-uri}" />

</p:declare-step>