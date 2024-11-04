<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsd">

    <!-- Identity transformation -->
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:param
        name="publicationDate"
        select="xsd:date(format-date(current-date(), '[Y0001]-[M01]-[D01]'))"
        as="xsd:date" />

    <xsl:param
        name="publisher"
        required="true" />
        
    <xsl:param
        name="location"
        required="true" />

    <xsl:template match="gc:CodeList/Annotation/Description">
        <Description>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="*" />
            <dcterms:available>
                <xsl:value-of select="$publicationDate" />
            </dcterms:available>
            <dcterms:publisher>
                <xsl:value-of select="$publisher" />
            </dcterms:publisher>
        </Description>
    </xsl:template>

    <xsl:template match="gc:CodeList/Identification">
        <xsl:copy>
            <xsl:apply-templates select="(ShortName|LongName|Version|CanonicalUri|CanonicalVersionUri)" />
            <LocationUri>
                <xsl:call-template name="constructLocationFormat">
                    <xsl:with-param name="fileExtension" select="'gc'" />
                </xsl:call-template>
            </LocationUri>
            <AlternateFormatLocationUri MimeType="text/csv">
                <xsl:call-template name="constructLocationFormat">
                    <xsl:with-param name="fileExtension" select="'csv'" />
                </xsl:call-template>
            </AlternateFormatLocationUri>
            <AlternateFormatLocationUri MimeType="text/html">
                <xsl:call-template name="constructLocationFormat">
                    <xsl:with-param name="fileExtension" select="'html'" />
                </xsl:call-template>
            </AlternateFormatLocationUri>
            <xsl:apply-templates select="Agency" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="constructLocationFormat">
        <!-- File extension, without dot at the start -->
        <xsl:param name="fileExtension" />
        <xsl:value-of select="$location || 'v' || Version || '.' || ShortName || '.' || $fileExtension" />
    </xsl:template>
    
</xsl:stylesheet>