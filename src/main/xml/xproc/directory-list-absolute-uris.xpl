<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    name="directory-list-absolute-uris"
    type="gt:directory-list-absolute-uris"
    version="3.1">

    <p:documentation>This step is a workaround for a bug in the current versions of the XProc processors, see also
        https://lists.w3.org/Archives/Public/xproc-dev/2025Feb/0013.html.
    </p:documentation>

    <p:output
        port="result"
        content-types="application/xml" />
    <p:option
        name="path"
        required="true"
        as="xsd:anyURI" />
    <p:option
        name="detailed"
        as="xsd:boolean"
        select="false()" />
    <p:option
        name="max-depth"
        as="xsd:string?"
        select="'1'" />
    <p:option
        name="include-filter"
        as="xsd:string*" />
    <p:option
        name="exclude-filter"
        as="xsd:string*" />
    <p:option
        name="override-content-types"
        as="array(array(xsd:string))?" />

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:directory-list
        name="directory-list"
        message="Produce list of contents with relative URIs of {$path}">
        <p:with-option
            name="path"
            select="$path" />
        <p:with-option
            name="detailed"
            select="$detailed" />
        <p:with-option
            name="max-depth"
            select="$max-depth" />
        <p:with-option
            name="include-filter"
            select="$include-filter" />
        <p:with-option
            name="exclude-filter"
            select="$exclude-filter" />
        <p:with-option
            name="override-content-types"
            select="$override-content-types" />
    </p:directory-list>

    <p:store
        name="store-directory-list-relative-uris"
        message="Store processed directory list with relative URIs for debugging"
        href="{'../../../../target/store-directory-list-relative-uris' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

    <p:xslt
        name="make-absolute-uris"
        message="Make xml:base attributes absolute URIs in list of contents of {$path}"
        version="3.0">
        <p:with-input port="stylesheet">
            <!-- See https://lists.w3.org/Archives/Public/xproc-dev/2025Feb/0015.html -->
            <p:inline>
                <xsl:stylesheet
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    version="3.0">

                    <xsl:output
                        method="xml"
                        encoding="utf-8"
                        indent="yes" />

                    <xsl:template match="*">
                        <xsl:copy>
                            <xsl:copy-of select="@*" />
                            <xsl:attribute
                                name="xml:base"
                                select="base-uri(.)" />
                            <xsl:apply-templates />
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:with-input>
    </p:xslt>

    <p:store
        name="store-directory-list-absolute-uris"
        message="Store processed directory list with absolute URIs for debugging"
        href="{'../../../../target/store-directory-list-absolute-uris-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
    </p:store>

</p:declare-step>