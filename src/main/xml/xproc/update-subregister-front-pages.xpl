<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xvrl="http://www.xproc.org/ns/xvrl"
    name="update-subregister-front-pages"
    type="gt:update-subregister-front-pages"
    version="3.0">

    <p:documentation>This step takes a directory containing directories, and
        
        * creates an Atom feed in each subdirectory;
        * updates the overview file index.html in each subdirectory:
          * an overview of the code lists present is added (based on the directory structure);
          * styling is added.

        It is assumed that
        * the top level directory represent the code list register overall;
        * the second level directories represent subregisters containing code lists;
        * the HTML and Atom encodings of the code list versions have been created already;
        * index.html files have been generated already in the subdirectories before calling this step (e.g. by AsciiDoctorj).

        This step has reads from and writes to a file system. It only has a report port, 
        where the results of the validation of the generated Atom files can be found,
        as that generation is dependent on the contents of the files read from the file system.
    </p:documentation>

    <p:import href="directory-list-absolute-uris.xpl" />
    
    <p:output
        port="report"
        primary="false"
        content-types="xml"
        serialization="map { 'indent': true() }">
        <p:pipe
            step="update-reports-subregisters-metadata"
            port="result" />
    </p:output>

    <p:option name="input-directory" />
    
    <!-- E.g. https://example.org/codelistregister/ 
    This option is needed to be able to construct the links in the feed. -->
    <p:option name="code-list-register-uri" />

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
            select="('.*\.html', '[^/]+/v[0-9]+\.[0-9]+\.[0-9]+\.[^/]+\.atom')" />
        <p:with-option
            name="max-depth"
            select="'3'" />
    </gt:directory-list-absolute-uris>

    <p:store
        name="store-directory-list"
        message="Store processed directory list for debugging"
        href="{'../../../../target/store-directory-list-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:for-each name="process-directory-list-subregister">
        <p:with-input select="/c:directory/c:directory" />
        
        <p:output
            port="report"
            primary="false"
            content-types="xml">
            <p:pipe
                step="create-and-store-feed"
                port="report" />
        </p:output>

        <p:store
            name="store-directory-list-subregister"
            message="Store directory list subregister for debugging"
            href="{'../../../../target/store-directory-list-subregister-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
            serialization="map { 'indent': true() }"
            use-when="$debug">
        </p:store>

        <!-- directory-uri will be absolute (cannot be seen in the debug files stored in the debug step above) -->
        <p:variable
            name="directory-uri"
            select="base-uri(/c:directory)" />
            
        <!-- E.g. https://example.org/codelistregister/subregister/ -->
        <p:variable
            name="code-list-subregister-uri"
            select="$code-list-register-uri || /c:directory/@name || '/'" />

        <p:variable
            name="overview-file-name"
            select="'index.html'" />

        <p:variable
            name="overview-file-uri"
            select="base-uri(/c:directory/c:file[@name eq $overview-file-name])" />

        <p:load
            name="load-index-html"
            message="Load {$overview-file-uri}"
            href="{$overview-file-uri}" />
            
        <p:group name="create-and-store-feed">
        
            <p:output
                port="report"
                primary="false"
                content-types="xml">
                <p:pipe
                    step="update-atom-validation-reports-metadata"
                    port="result" />
            </p:output>

            <p:variable
                name="feed-file-name"
                select="'feed.atom'" />

            <p:variable
                name="feed-file-uri"
                select="base-uri(/c:directory) || $feed-file-name">
                <p:pipe
                    step="process-directory-list-subregister"
                    port="current" />
            </p:variable>

            <p:xslt
                name="convert-index-html-to-feed"
                message="Convert index.html to empty feed">
                <p:with-input port="source">
                    <p:pipe
                        step="load-index-html"
                        port="result" />
                </p:with-input>
                <p:with-input
                    port="stylesheet"
                    href="../xslt/html2atom.xsl" />
                <p:with-option
                    name="parameters"
                    select="map {'codeListSubregisterUri' : $code-list-subregister-uri, 'overviewFileName' : $overview-file-name, 'feedFileName' : $feed-file-name }" />
            </p:xslt>

            <p:for-each name="load-atom-entry-files">
                <p:with-input select="/c:directory/c:directory/c:file[ends-with(@name, '.atom')]">
                    <p:pipe
                        step="process-directory-list-subregister"
                        port="current" />
                </p:with-input>
                <p:output port="result">
                    <p:pipe
                        step="load-atom-entry-file"
                        port="result" />
                </p:output>

                <p:variable
                    name="atom-entry-file-uri"
                    select="base-uri(c:file)" />

                <p:load
                    name="load-atom-entry-file"
                    message="Load {$atom-entry-file-uri}"
                    href="{$atom-entry-file-uri}"
                    content-type="application/atom+xml" />
            </p:for-each>

            <p:insert
                name="insert-atom-entries-in-feed"
                message="Insert Atom entries in feed">
                <p:with-input port="source">
                    <p:pipe
                        step="convert-index-html-to-feed"
                        port="result" />
                </p:with-input>
                <p:with-input port="insertion">
                    <p:pipe
                        step="load-atom-entry-files"
                        port="result" />
                </p:with-input>
                <p:with-option
                    name="match"
                    select="'/atom:feed/atom:updated'" />
                <p:with-option
                    name="position"
                    select="'after'" />
            </p:insert>

            <p:xslt
                name="sort-atom-entries-from-most-to-least-recent"
                message="Sort Atom entries from most to least recent">
                <p:with-input
                    port="stylesheet"
                    href="../xslt/sort-atom-entries.xsl" />
            </p:xslt>
            
            <!-- New stylesheet just for updating the timestamp,
            otherwise sort-atom-entries.xsl would be harder to test. -->
            <p:xslt
                name="update-feed-timestamp"
                message="Update time of last feed update">
                <p:with-input
                    port="stylesheet"
                    href="../xslt/update-feed-updated.xsl" />
            </p:xslt>

            <p:set-properties>
                <p:with-option
                    name="properties"
                    select="map{ 'base-uri' : $feed-file-uri}" />
            </p:set-properties>
            
            <!-- Note: opposed to most other p:store steps, this step is part of the production flow,
            it's purpose is not debugging. -->
            <p:store
                name="store-feed"
                message="Store Atom feed {$feed-file-uri}"
                href="{$feed-file-uri}"
                serialization="map { 'indent': true() }" />

            <!-- 
            If the RELAX NG validation fails:
            linearize the Atom feed to find the location indicated by
            xvrl:location/@line and xvrl:location/@column
            in the validation report  -->
            <p:validate-with-relax-ng
                name="validate-atom-feed-relax-ng"
                message="Validate Atom feed with RELAX NG schema">
                <p:with-input
                    port="schema"
                    href="../schemas/relaxng/atom.rnc" />
            <p:with-option
                    name="assert-valid"
                    select="false()" />
            </p:validate-with-relax-ng>

            <p:validate-with-schematron
                name="validate-atom-feed-schematron"
                message="Validate Atom feed with Schematron schema">
                <p:with-input
                    port="schema"
                    href="../schemas/schematron/atom.sch" />
                <p:with-option
                    name="assert-valid"
                    select="false()" />
                <!--  TODO find a good way to reuse step validate-with-schematron-xvrl from genericode-validator -->
                <p:with-option
                    name="report-format"
                    select="'xvrl'" />
            </p:validate-with-schematron>
            
            <p:wrap-sequence
                name="collect-atom-validation-reports"
                message="Collect all Atom validation reports">
                <p:with-input port="source">
                    <p:pipe
                        step="validate-atom-feed-relax-ng"
                        port="report" />
                    <p:pipe
                        step="validate-atom-feed-schematron"
                        port="report" />
                </p:with-input>
                <p:with-option
                    name="wrapper"
                    select="QName('http://www.xproc.org/ns/xvrl', 'reports')" />
            </p:wrap-sequence>
            
            <p:variable
                name="is-atom-valid"
                select="not(exists(/xvrl:reports/xvrl:report/xvrl:digest[@valid eq 'false']))" />
            
            <p:insert
                name="update-atom-validation-reports-metadata"
                message="{if ($is-atom-valid) then $feed-file-uri || ' is valid' else ('WARNING ' || $feed-file-uri || ' is NOT valid')}">
                <p:with-input port="insertion">
                    <p:inline exclude-inline-prefixes="#all">
                        <metadata xmlns="http://www.xproc.org/ns/xvrl">
                            <document href="{$feed-file-uri}"/>
                        </metadata>
                        <digest xmlns="http://www.xproc.org/ns/xvrl" valid="{$is-atom-valid}" />
                    </p:inline>
                </p:with-input>
                <p:with-option
                    name="match"
                    select="'/xvrl:reports'" />
                <p:with-option
                    name="position"
                    select="'first-child'" />
            </p:insert>
            
        </p:group>
        
        <p:group name="update-overview-file">

            <p:variable
                name="lang"
                select="/xhtml:html/@lang">
                <p:pipe
                    step="load-index-html"
                    port="result" />
            </p:variable>

            <p:xslt
                name="convert-code-list-directory-to-html-element"
                message="Create HTML element from file names in {$directory-uri}">
                <p:with-input port="source">
                    <p:pipe
                        step="process-directory-list-subregister"
                        port="current" />
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
    
            <!-- Note: opposed to most other p:store steps, this step is part of the production flow,
            it's purpose is not debugging.
            The original overview file is overwritten. -->
            <p:store
                name="store-overview-file"
                message="Overwrite overview file in {$overview-file-uri}"
                href="{$overview-file-uri}" />
            
        </p:group>
    </p:for-each>
    
    <p:wrap-sequence
        name="collect-reports-subregisters"
        message="Collect reports from all subregisters">
        <p:with-input port="source">
            <p:pipe
                step="process-directory-list-subregister"
                port="report" />
        </p:with-input>
        <p:with-option
            name="wrapper"
            select="QName('http://www.xproc.org/ns/xvrl', 'reports')" />
    </p:wrap-sequence>
    
    <p:insert
        name="update-reports-subregisters-metadata"
        message="Update metadata for reports from all subregisters">
        <p:with-input port="insertion">
            <p:inline exclude-inline-prefixes="#all">
                <metadata xmlns="http://www.xproc.org/ns/xvrl">
                    <title>Report from XProc step update-subregister-front-pages</title>
                </metadata>
            </p:inline>
        </p:with-input>
        <p:with-option
            name="match"
            select="'/xvrl:reports'" />
        <p:with-option
            name="position"
            select="'first-child'" />
    </p:insert>

</p:declare-step>