<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xvrl="http://www.xproc.org/ns/xvrl"
    name="generate-code-list-register-site"
    type="gt:generate-code-list-register-site"
    version="3.1">

    <p:documentation>This step takes a directory representing a code list register and generates a site for it.
    
        It is assumed that the directory that has the following structure:
        * the top-level directory contains files index.html, README.adoc and a directory for each subregister;
        * the 2nd level directories contain files index.html, README.adoc and a directory for each code list;
        * the 3rd level directories contain a file for each version of a code lists, following pattern v1.2.3.codelist.gc.

        The 3rd
        level directories possibly also contain files index.html, v1.2.3.codelist.csv, v1.2.3.codelist.html,
        v1.2.3.codelist.atom and v1.2.3.codelist.rdf if the site has been generated earlier.
    </p:documentation>
    
    <p:import href="transform-and-store-codelists.xpl" />
    <p:import href="create-code-list-version-overviews.xpl" />
    <p:import href="update-subregister-front-pages.xpl" />
    <p:import href="update-front-page.xpl" />
    
    <p:output
        port="report"
        primary="false"
        content-types="xml"
        serialization="map { 'indent': true() }">
        <p:pipe
            step="update-reports-metadata"
            port="result" />
    </p:output>

    <p:option name="input-directory" />
    
    <!-- E.g. https://example.org/codelistregister/ -->
    <p:option name="code-list-register-uri" />
    
    <p:option
        name="overwrite-existing-alternative-formats"
        as="xsd:boolean"
        select="false()" />

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:variable
        name="input-directory-urified"
        select="p:urify($input-directory)" />

    <gt:transform-and-store-codelists
        name="transform-and-store-codelists"
        p:message="Transform and store code lists">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
        <p:with-option
            name="overwrite-existing-alternative-formats"
            select="$overwrite-existing-alternative-formats" />
        <p:with-option
            name="code-list-register-uri"
            select="$code-list-register-uri" />
    </gt:transform-and-store-codelists>

    <!-- This step assumes that the HTML encodings of all code lists have been created already.
    Therefore, an explicit dependency on the step creating those HTML encodings is added. -->
    <gt:create-code-list-version-overviews
        name="create-code-list-version-overviews"
        p:message="Create code list version overviews"
        p:depends="transform-and-store-codelists">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
    </gt:create-code-list-version-overviews>

    <!-- This step assumes that the HTML encodings of all code lists have been created already.
    Therefore, as a minimum an explicit dependency on the step creating those HTML encodings has to be present.
    However, to enforce a sequential execution of the steps (as opposed to a parallel execution),
    this step has an explicit dependency on the previous step. This will make the XProc processor output
    easier to read for the user. -->
    <gt:update-subregister-front-pages
        name="update-subregister-front-pages"
        p:message="Update subregister front pages"
        p:depends="create-code-list-version-overviews">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
        <p:with-option
            name="code-list-register-uri"
            select="$code-list-register-uri" />
    </gt:update-subregister-front-pages>

    <!-- This step reads the index.html files in the subregisters. Those files are updated
    in the previous step.
    Therefore, this step has an explicit dependency on the previous step. -->
    <gt:update-front-page
        name="update-front-page"
        p:message="Update code list register front page"
        p:depends="update-subregister-front-pages">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
    </gt:update-front-page>
    
    <!-- Gather reports from previous steps. -->
    <p:wrap-sequence
        name="collect-reports"
        message="Collect reports from steps">
        <p:with-input port="source">
            <p:pipe
                step="update-subregister-front-pages"
                port="report" />
        </p:with-input>
        <p:with-option
            name="wrapper"
            select="QName('http://www.xproc.org/ns/xvrl', 'reports')" />
    </p:wrap-sequence>
    
    <p:insert
        name="update-reports-metadata"
        message="Update metadata for reports from steps">
        <p:with-input port="insertion">
            <p:inline exclude-inline-prefixes="#all">
                <metadata xmlns="http://www.xproc.org/ns/xvrl">
                    <title>Report from XProc step generate-code-list-register-site</title>
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