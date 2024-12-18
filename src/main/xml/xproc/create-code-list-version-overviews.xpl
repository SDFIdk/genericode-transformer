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
    name="create-code-list-version-overviews"
    type="gt:create-code-list-version-overviews"
    version="3.0">

    <p:documentation>This step takes a directory containing versions of code lists in the different formats,
        in the directory itself and in its subdirectories,
        and creates an overview file index.html for each code list, in the directory structure that is provided as input.
        It is assumed that
        * all the versions of a specific code list are in the same folder;
        * the file names of the code list version follow the pattern v1.2.3.codelist.html, v1.2.3.codelist.gc, etc.
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
        <!-- v1.2.3.codelist.html must match,
        index.html (created in earlier executions of this step) must not match,
        v1.2.3.codelist.gc must not match
         -->
        <p:with-option
            name="include-filter"
            select="'v[0-9]+\.[0-9]+\.[0-9]+\..*\.html'" />
        <p:with-option
            name="max-depth"
            select="'unbounded'" />
    </p:directory-list>

    <p:store
        name="store-directory-list"
        message="Store processed directory list for debugging"
        href="{'../../../../target/store-directory-list-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:for-each>
        <p:with-input select="//c:directory[exists(c:file)]" />

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
            select="p:urify($directory-uri || 'index.html')" />

        <p:variable
            name="latest-version-html-uri"
            select="let $regex := '^v(([0-9]+)\.([0-9]+)\.([0-9]+))\..*',
                    $files := /c:directory/c:file,
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
                    return base-uri($filesSortedOnVersionAscending[last()])" />

        <p:variable
            name="latest-version-gc-uri"
            select="replace($latest-version-html-uri, '.html', '.gc')" />

        <p:xslt
            name="convert-code-list-version-directory-to-html-element"
            message="Create HTML element from file names in {$directory-uri}">
            <p:with-input
                port="stylesheet"
                href="../xslt/convert-code-list-version-directory-to-html-element.xsl" />
        </p:xslt>

        <p:store
            name="store-version-html-element"
            message="Store HTML list for debugging"
            href="{'../../../../target/store-version-html-element-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
            serialization="map { 'indent': true() }"
            use-when="$debug">
        </p:store>

        <p:load
            name="load-latest-version"
            message="Load latest code list version to retrieve certain metadata elements to be included in the overview page: {$latest-version-gc-uri}"
            href="{$latest-version-gc-uri}"
            content-type="application/xml" />

        <p:variable
            name="lang-latest-version"
            select="/gc:CodeList/Annotation/Description/dcterms:language" />

        <p:variable
            name="name-latest-version"
            select="/gc:CodeList/Identification/ShortName" />

        <p:variable
            name="version-html-element"
            select="/">
            <p:pipe
                step="convert-code-list-version-directory-to-html-element"
                port="result" />
        </p:variable>

        <p:xslt
            name="create-code-list-version-overview-page"
            message="Create code list version overview page for {$name-latest-version} in language {$lang-latest-version}">
            <p:with-input
                port="stylesheet"
                href="../xslt/create-codelist-version-overview.xsl" />
            <p:with-option
                name="template-name"
                select="'start-template'" />
            <p:with-option
                name="parameters"
                select="map {'lang' : $lang-latest-version, 'codeListName' : $name-latest-version, 'versionElement' : $version-html-element }" />
        </p:xslt>

        <!-- Note: opposed to the other p:store steps, this step is part of the production flow,
        it's purpose is not debugging. -->
        <p:store
            name="store-overview-file"
            message="Store overview file in {$overview-file-uri}"
            href="{$overview-file-uri}" />
    </p:for-each>

</p:declare-step>