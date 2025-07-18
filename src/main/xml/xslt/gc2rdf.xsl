<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	exclude-result-prefixes="xsl gc xsd"
    >
    
    <!-- 
    Stylesheet that converts a genericode file to a RDF file with using SKOS format.
    -->
    
    <xsl:output indent="yes" method="xml" />
    
	<!-- See https://www.w3.org/TR/xslt-30/#element-mode and https://www.w3.org/TR/xslt-30/#built-in-templates-shallow-skip -->
    <xsl:mode on-no-match="shallow-skip" />
	
	<xsl:variable
			name="creationdate"
			select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xsd:dayTimeDuration('PT0S')), '[Y0001]-[M01]-[D01]')"
			as="xsd:string" />
			
	<xsl:variable name="location" select="/gc:CodeList/Identification/LocationUri" />
	<xsl:variable name="registerlocation" select="substring-before($location, '/v')"/>
	
	<xsl:variable name="language" select="/gc:CodeList/Annotation/Description/dcterms:language" />
	
    <xsl:template match="/gc:CodeList">
		<xsl:document>
			<rdf:RDF>
				<skos:ConceptScheme rdf:about="{$registerlocation}">
					
					<dcterms:title xml:lang="{$language}">
						<xsl:value-of select="Identification/ShortName" />
					</dcterms:title>
					
					<dcterms:identifier>
						<xsl:value-of select="Identification/CanonicalUri" />
					</dcterms:identifier>
					
					<owl:sameAs rdf:resource="{Identification/CanonicalUri}" />
					
					<dcterms:creator xml:lang="{$language}">
						<xsl:value-of select="Identification/Agency/LongName" />
					</dcterms:creator>
					
					<dcterms:description xml:lang="{$language}">
						<xsl:value-of select="Annotation/Description/dcterms:description" />
					</dcterms:description>
					
					<dcterms:provenance xml:lang="{$language}">
						<xsl:value-of select="Annotation/Description/dcterms:provenance" />
					</dcterms:provenance>
					
					<dcterms:license>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="Annotation/Description/dcterms:license" />
						</xsl:attribute>
					</dcterms:license>
					
					<xsl:copy-of select="Annotation/Description/dcterms:available" />
					
					<rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset" />
					
					<dcat:version rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="Identification/Version" />
					</dcat:version>
					
					<dcat:version rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">
						<xsl:value-of select="Identification/CanonicalVersionUri" />
					</dcat:version>
					
					<dcat:distribution rdf:resource="{$location}" />
					
					<xsl:apply-templates select="Identification/AlternateFormatLocationUri" mode="distributionProperty" />
					
				</skos:ConceptScheme>
				
				<dcat:Distribution rdf:about="{$location}">
					<dcterms:format rdf:resource="https://www.iana.org/assignments/media-types/application/xml" />
				</dcat:Distribution>
				
				<xsl:apply-templates select="Identification/AlternateFormatLocationUri" mode="distributionClass" />
				
				<xsl:apply-templates select="SimpleCodeList/Row" />
				
			</rdf:RDF>
		</xsl:document>
    </xsl:template>
	
	<xsl:template match="Row">
		<skos:Concept rdf:about="{$registerlocation}/{Value[@ColumnRef = 'navn']/SimpleValue}">
			
			<skos:inScheme rdf:resource="{$registerlocation}" />
			
			<skos:topConceptOf rdf:resource="{$registerlocation}" />
			
			<skos:notation>
				<xsl:value-of select="Value[@ColumnRef = 'kode']/SimpleValue" />
			</skos:notation>
			
			<skos:prefLabel xml:lang="{$language}">
				<xsl:value-of select="Value[@ColumnRef = 'navn']/SimpleValue" />
			</skos:prefLabel>
			
			<skos:definition xml:lang="{$language}">
				<xsl:value-of select="Value[@ColumnRef = 'definition']/SimpleValue" />
			</skos:definition>
			
			<xsl:if test="Value[@ColumnRef = 'kommentar']/SimpleValue != ''">
				<rdfs:comment xml:lang="{$language}">
					<xsl:value-of select="Value[@ColumnRef = 'kommentar']/SimpleValue" />
				</rdfs:comment>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="exists(Value[@ColumnRef = 'virkningTil']/SimpleValue)">
					<dcterms:valid>
						<xsl:value-of select="Value[@ColumnRef = 'virkningFra']/SimpleValue || '/' || Value[@ColumnRef = 'virkningTil']/SimpleValue" />
					</dcterms:valid>
				</xsl:when>
				<xsl:otherwise>
					<dcterms:valid>
						<xsl:value-of select="Value[@ColumnRef = 'virkningFra']/SimpleValue || '/..'" />
					</dcterms:valid>
				</xsl:otherwise>
			</xsl:choose>
			
		</skos:Concept>
	</xsl:template>
	
	<xsl:template match="AlternateFormatLocationUri" 
				  mode="distributionProperty">
		<dcat:distribution rdf:resource="{.}" />
	</xsl:template>
	
	<xsl:template match="gc:CodeList/Identification/AlternateFormatLocationUri" 
				  mode="distributionClass">
		<xsl:variable name="buildIanaLink" select="'https://www.iana.org/assignments/media-types/'" />
		<dcat:Distribution rdf:about="{.}">
			<dcterms:format rdf:resource="{$buildIanaLink}{./@MimeType}" />
		</dcat:Distribution>
		
	</xsl:template>
	
</xsl:stylesheet>