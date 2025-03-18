<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="xsd gc dcterms">
	
	<xsl:output indent="yes" method="xml" />

    <!-- Identity transformation -->
    <xsl:mode on-no-match="shallow-copy" />
	
	<xsl:variable
        name="updated"
		static="yes"
        select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xsd:dayTimeDuration('PT0S')), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z00:00t]')"
        as="xsd:string" />
	
	<xsl:template match="/gc:CodeList">
		<entry>
			<title type="text"><xsl:value-of select="Identification/ShortName || ' version ' || Identification/Version" /></title>
			<id><xsl:value-of select="Identification/CanonicalVersionUri" /></id>
			<updated><xsl:value-of select="$updated"/></updated>
			<xsl:apply-templates select="Annotation/Description/dcterms:available" />
			<xsl:apply-templates select="Identification/AlternateFormatLocationUri[@MimeType='text/html']" />
			<summary type="text"><xsl:value-of select="Annotation/Description/dcterms:provenance" /></summary>
			<content type="html"><xsl:value-of select="'&#60;div&#62;' || Annotation/Description/dcterms:provenance || '&#60;/div&#62;'" /></content>
		</entry>
	</xsl:template>
	
	<xsl:template match="AlternateFormatLocationUri">
		<link rel="alternate">
			<xsl:attribute name="type">
				<xsl:value-of select="'text/html'" />
			</xsl:attribute>
			
			<xsl:attribute name="href">
				<xsl:value-of select="." />
			</xsl:attribute>
		</link>
	</xsl:template>
	
	<xsl:template match="dcterms:available">
		<published>
			<xsl:value-of select="concat(format-date(., '[Y0001]-[M01]-[D01]'), 'T00:00:00Z')" />
		</published>
	</xsl:template>	
	
</xsl:stylesheet>