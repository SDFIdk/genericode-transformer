<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:msg="urn:uuid:74875954-5193-4fb8-ba48-9944e9a36c80"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	
    
    <!-- 
    Stylesheet with common functionality for localization (l10n),
    to be included in other stylesheets that need localization.
    -->
    
    <!-- Prerequisite: variable lang is defined in the stylesheet that includes this stylesheet directly or indirectly -->
    <xsl:variable
        name="localizedMessages"
        select="document(concat('../../resources/locale/', $lang, '.xml'))/msg:messages" />

    <xsl:template name="localizedMessage">
        <xsl:param name="id" />
        <xsl:choose>
            <xsl:when test="exists($localizedMessages/msg:message[@id=$id])">
                <xsl:value-of select="string($localizedMessages/msg:message[@id=$id])" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:value-of select="'WARNING: No message with id &#34;' || $id || '&#34; is defined for language ' || $lang || '.'" />
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
</xsl:stylesheet>