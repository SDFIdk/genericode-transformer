<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsd">
    
    <!-- 
    Stylesheet that adds/updates the publication information to/of a genericode file.
    -->

    <xsl:output
        method="xml"
        encoding="UTF-8"
        indent="yes" />

    <!-- Identity transformation -->
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:param
        name="publicationDate"
        select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"
        as="xsd:string" />

    <!-- E.g. https://example.org/codelistregister/subregister/ -->
    <xsl:param
        name="codeListSubregisterUri"
        as="xsd:anyURI"
        required="true" />

    <xsl:param
        name="addCsvAsAlternateFormat"
        select="true()"
        as="xsd:boolean" />

    <xsl:param
        name="addRdfAsAlternateFormat"
        select="true()"
        as="xsd:boolean" />

    <xsl:template match="gc:CodeList/Annotation/Description">
        <Description>
            <xsl:apply-templates select="@*" />
            <!-- Overwrite dcterms:available if it is present -->
            <xsl:apply-templates select="*[name() ne 'dcterms:available']" />
            <dcterms:available>
                <xsl:value-of select="$publicationDate" />
            </dcterms:available>
        </Description>
    </xsl:template>

    <xsl:template match="gc:CodeList/Identification">
        <xsl:copy>
            <xsl:apply-templates select="ShortName|LongName|Version|CanonicalUri|CanonicalVersionUri" />
            <LocationUri>
                <xsl:call-template name="constructLocationFormat">
                    <xsl:with-param
                        name="fileExtension"
                        select="'gc'" />
                </xsl:call-template>
            </LocationUri>
            <xsl:if test="$addCsvAsAlternateFormat">
                <AlternateFormatLocationUri MimeType="text/csv">
                    <xsl:call-template name="constructLocationFormat">
                        <xsl:with-param
                            name="fileExtension"
                            select="'csv'" />
                    </xsl:call-template>
                </AlternateFormatLocationUri>
            </xsl:if>
            <AlternateFormatLocationUri MimeType="text/html">
                <xsl:call-template name="constructLocationFormat">
                    <xsl:with-param
                        name="fileExtension"
                        select="'html'" />
                </xsl:call-template>
            </AlternateFormatLocationUri>
            <xsl:if test="$addRdfAsAlternateFormat">
                <AlternateFormatLocationUri MimeType="application/rdf+xml">
                    <xsl:call-template name="constructLocationFormat">
                        <xsl:with-param
                            name="fileExtension"
                            select="'rdf'" />
                    </xsl:call-template>
                </AlternateFormatLocationUri>
            </xsl:if>
            <xsl:apply-templates select="Agency" />
        </xsl:copy>
    </xsl:template>

    <xsl:template name="constructLocationFormat">
        <!-- File extension, without dot at the start -->
        <xsl:param
            name="fileExtension"
            required="yes"
            as="xsd:string" />
        <xsl:value-of
            select="(if (ends-with($codeListSubregisterUri, '/')) then $codeListSubregisterUri else $codeListSubregisterUri || '/') || ShortName || '/v' || Version || '.' || ShortName || '.' || $fileExtension" />
    </xsl:template>

</xsl:stylesheet>