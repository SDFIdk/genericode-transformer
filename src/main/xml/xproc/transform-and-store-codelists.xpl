<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    name="transform-and-store-codelists"
    type="gt:transform-and-store-codelists"
    version="3.0">

    <p:documentation>This step takes a directory containing versions of code lists in genericode (GC),
        in the directory itself and in its subdirectories,
        and creates the CSV and HTML encodings of each code list version, in the directory structure that is provided as input.
        So v1.2.3.codelist.csv and v1.2.3.codelist.html will be saved in the same directory as v1.2.3.codelist.gc is present in.
        It is assumed that the file names follow the pattern v1.2.3.codelist.html, v1.2.3.codelist.gc, etc.
        
        This step has neither input nor output ports. It reads from and writes to a file system.
    </p:documentation>

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

    <p:directory-list
        name="create-directory-list"
        message="Produce list of contents of {$input-directory}">
        <p:with-option
            name="path"
            select="$input-directory-urified" />
        <!-- v1.2.3.codelist.gc must match,
        v1.2.3.codelist.csv must match,
        v1.2.3.codelist.html must match
        Later on it is checked whether the CSV/HTML encodings already exist.
         -->
        <p:with-option
            name="include-filter"
            select="'v[0-9]+\.[0-9]+\.[0-9]+\..*\.[gc|csv|html]'" />
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

    <p:for-each name="transform-for-each">
        <p:with-input select="//c:file[ends-with(@name, '.gc')]" />

        <p:variable
            name="gc-name"
            select="/c:file/@name" />

        <p:variable
            name="base-uri-gc"
            select="base-uri(/c:file)" />

        <p:load
            name="load-gc"
            message="Load {$gc-name} from {$base-uri-gc}"
            href="{$base-uri-gc}"
            content-type="application/xml" />

        <p:variable
            name="base-uri-csv"
            select="replace($base-uri-gc, '.gc', '.csv')" />

        <p:variable
            name="csv-exists"
            select="exists(//c:file[base-uri() eq $base-uri-csv])">
            <p:pipe
                step="create-directory-list"
                port="result" />
        </p:variable>

        <p:choose>
            <p:when test="$overwrite-existing-alternative-formats or not($csv-exists)">
                <p:xslt
                    name="gc2csv"
                    message="Transform {$base-uri-gc} to CSV">
                    <p:with-input port="source">
                        <p:pipe
                            step="load-gc"
                            port="result" />
                    </p:with-input>
                    <p:with-input
                        port="stylesheet"
                        href="../xslt/gc2csv.xsl" />
                </p:xslt>

                <p:store
                    name="store-csv"
                    message="Store CSV code list in {$base-uri-csv}"
                    href="{$base-uri-csv}" />
            </p:when>
            <p:otherwise>
                <p:identity message="Do not transform {$gc-name} to CSV as {$base-uri-csv} already exists" />
            </p:otherwise>
        </p:choose>

        <p:variable
            name="base-uri-html"
            select="replace($base-uri-gc, '.gc', '.html')" />

        <p:variable
            name="html-exists"
            select="exists(//c:file[base-uri() eq $base-uri-html])">
            <p:pipe
                step="create-directory-list"
                port="result" />
        </p:variable>

        <p:choose>
            <p:when test="$overwrite-existing-alternative-formats or not($html-exists)">
                <p:xslt
                    name="gc2html"
                    message="Transform {$base-uri-gc} to HTML">
                    <p:with-input port="source">
                        <p:pipe
                            step="load-gc"
                            port="result" />
                    </p:with-input>
                    <p:with-input
                        port="stylesheet"
                        href="../xslt/gc2html.xsl" />
                </p:xslt>

                <p:store
                    name="store-html"
                    message="Store HTML code list in {$base-uri-html}"
                    href="{$base-uri-html}" />
            </p:when>
            <p:otherwise>
                <p:identity message="Do not transform {$gc-name} to HTML as {$base-uri-html} already exists" />
            </p:otherwise>
        </p:choose>
    </p:for-each>

</p:declare-step>