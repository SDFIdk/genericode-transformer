<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    name="add-publication-details-to-gc"
    version="3.1">

    <p:documentation>This step
        (1) Normalizes the namespaces in the genericode file;
        (2) Adds/updates the publication information to/of a genericode file.
        
        This means the the genericode file that is given as input is UPDATED.
    </p:documentation>

    <!-- E.g.: C:\path\to\codelist.gc -->
    <p:option
        name="gc-file-path"
        required="true" />
        
    <!-- E.g. https://example.org/codelistregister/subregister/ -->
    <p:option
        name="code-list-subregister-uri"
        required="true" />

    <p:option
        name="add-csv-as-alternate-format"
        as="xsd:boolean"
        select="true()" />
        
    <p:option
        name="add-rdf-as-alternate-format"
        as="xsd:boolean"
        select="true()" />

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:variable
        name="gc-file-path-urified"
        select="p:urify($gc-file-path)" />

    <p:load
        name="load-gc-file"
        message="Load {$gc-file-path-urified}"
        href="{$gc-file-path-urified}" />
    
    <!-- Normalizing namespaces ensures a uniform notation of namespace declararations 
    in the genericode files in the code list register.
    Do this before adding the publication details, so the serialization parameters
    of the next stylesheet are used when storing the genericode file again.  -->
    <p:xslt
        name="normalize-namespaces"
        message="Normalize the namespaces">
        <p:with-input
            port="stylesheet"
            href="../xslt/normalize-namespaces.xsl" />
    </p:xslt>

    <p:xslt
        name="add-publication-details"
        message="Add/update the publication details. Formats: add CSV URI: {$add-csv-as-alternate-format}; add RDF URI: {$add-rdf-as-alternate-format}">
        <p:with-input
            port="stylesheet"
            href="../xslt/add-publication-details-to-gc.xsl" />
        <p:with-option
            name="parameters"
            select="map {'codeListSubregisterUri' : $code-list-subregister-uri, 
                         'addCsvAsAlternateFormat' : $add-csv-as-alternate-format, 
                         'addRdfAsAlternateFormat' : $add-rdf-as-alternate-format }" />
    </p:xslt>

    <p:store
        name="store-gc-file"
        message="Store {$gc-file-path-urified}"
        href="{$gc-file-path-urified}" />

</p:declare-step>