<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    name="generate-code-list-register-site"
    type="gt:generate-code-list-register-site"
    version="3.0">

    <p:documentation>This step takes a directory represent a code list register and generates a site for it.
        It is assumed that the directory that has the following structure:
        * the top-level directory contains files index.html, README.adoc and a directory for each subregister;
        * the 2nd level directories contain files index.html, README.adoc and a directory for each code list;
        * the 3rd level directories contain a file for each version of a code lists, following pattern v1.2.3.codelist.gc,

        The 3rd
        level directories possibly also contain files index.html, v1.2.3.codelist.csv and v1.2.3.codelist.html, if the site has been generated earlier.
    </p:documentation>
    
    <p:import href="transform-and-store-codelists.xpl" />
    <p:import href="create-code-list-version-overviews.xpl" />
    <p:import href="update-subregister-front-pages.xpl" />
    <p:import href="update-front-page.xpl" />

    <p:option name="input-directory" />
    
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
    </gt:transform-and-store-codelists>

    <gt:create-code-list-version-overviews
        name="create-code-list-version-overviews"
        p:message="Create code list version overviews">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
    </gt:create-code-list-version-overviews>

    <gt:update-subregister-front-pages
        name="update-subregister-front-pages"
        p:message="Update subregister front pages">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
    </gt:update-subregister-front-pages>

    <gt:update-front-page
        name="update-front-page"
        p:message="Update code list register front page">
        <p:with-option
            name="input-directory"
            select="$input-directory" />
    </gt:update-front-page>

</p:declare-step>