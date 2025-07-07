<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    name="retrieve-processor-properties"
    version="3.1">

    <p:output
        port="result"
        primary="true"
        content-types="text/plain"
        serialization="map { 'indent': true() }">
    </p:output>

    <p:option
        name="debug"
        as="xsd:boolean"
        select="false()"
        static="true" />

    <p:identity name="retrieve-xproc-processor-properties">
        <p:with-input
            port="source"
            exclude-inline-prefixes="#all">
            <configuration>
                <xproc-processor>{p:system-property('p:product-name')} {p:system-property('p:product-version')}</xproc-processor>
            </configuration>
        </p:with-input>
    </p:identity>

    <p:xslt name="add-xslt-processor-properties">
        <p:with-input
            port="stylesheet"
            exclude-inline-prefixes="dct rdf sch skos svrl xsd">
            <xsl:stylesheet version="3.0">

                <xsl:mode on-no-match="shallow-copy" />

                <xsl:template match="/configuration">
                    <xsl:copy>
                        <xsl:apply-templates select="*" />
                        <xslt-processor>
                            <xsl:value-of select="system-property('xsl:product-name')" />
                            <xsl:value-of select="' '" />
                            <xsl:value-of select="system-property('xsl:product-version')" />
                        </xslt-processor>
                    </xsl:copy>
                </xsl:template>
            </xsl:stylesheet>
        </p:with-input>
    </p:xslt>

    <p:validate-with-schematron name="use-schematron-processor">
        <p:with-input port="schema">
            <sch:schema queryBinding="xslt2">
                <sch:pattern>
                    <sch:rule context="/">
                        <sch:assert test="true()" />
                    </sch:rule>
                </sch:pattern>
            </sch:schema>
        </p:with-input>
    </p:validate-with-schematron>

    <p:store
        name="store-schematron-report"
        message="Store Schematron report for debugging"
        href="{'../../../../target/store-schematron-report-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
        serialization="map { 'indent': true() }"
        use-when="$debug">
        <p:with-input>
            <p:pipe
                step="use-schematron-processor"
                port="report" />
        </p:with-input>
    </p:store>
    
    <!-- SchXslt is assumed, with this select expression -->
    <p:variable
        name="schxslt-user-agent"
        select="/svrl:schematron-output/svrl:metadata/dct:source/rdf:Description/dct:creator/dct:Agent/skos:prefLabel/text()">
        <p:pipe
            step="use-schematron-processor"
            port="report" />
    </p:variable>

    <p:insert name="add-schematron-processor-property">
        <p:with-input port="source">
            <p:pipe
                step="use-schematron-processor"
                port="result" />
        </p:with-input>
        <p:with-input
            port="insertion"
            exclude-inline-prefixes="#all">
            <schematron-processor>{$schxslt-user-agent}</schematron-processor>
        </p:with-input>
        <p:with-option
            name="match"
            select="'/configuration'" />
        <p:with-option
            name="position"
            select="'last-child'" />
    </p:insert>

    <p:xslt name="xml2txt">
        <p:with-input
            port="stylesheet"
            exclude-inline-prefixes="#all">
            <xsl:stylesheet version="3.0">

                <xsl:output
                    method="text"
                    encoding="UTF-8" />

                <xsl:template match="/configuration">
                        <xsl:apply-templates select="*" />
                </xsl:template>
                
                <xsl:template match="/configuration/*">
                        <xsl:value-of select="local-name()" />
                        <xsl:value-of select="': '" />
                        <xsl:value-of select="text()" />
                        <xsl:value-of select="'&#x000D;&#x000A;'" />
                </xsl:template>
                
            </xsl:stylesheet>
        </p:with-input>
    </p:xslt>

</p:declare-step>