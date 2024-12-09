<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:msg="urn:uuid:74875954-5193-4fb8-ba48-9944e9a36c80"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet with common functionality for generating HTML pages,
    to be included in other stylesheets that generate HTML pages.
    -->

    <xsl:variable
        name="designsystemVersion"
        select="'8'" />

    <xsl:variable
        name="designsystemUrl"
        select="'https://cdn.dataforsyningen.dk/assets/designsystem/v' || $designsystemVersion" />

    <xsl:variable
        name="arrowLeftIcon"
        select="document($designsystemUrl || '/icons/arrow-left.svg')" />

    <xsl:variable
        name="mailIcon"
        select="document($designsystemUrl || '/icons/mail.svg')" />

    <!-- Prerequisite: variable lang is defined in the stylesheet that includes this stylesheet -->
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

    <!-- Prerequisite: DSLogoTitle has been imported from designsystem.js in the stylesheet that includes this stylesheet -->
    <xsl:template name="generateHtmlFooter">
        <footer class="ds-footer">
            <div class="ds-container">
                <ds-logo-title class="transparent">
                    <xsl:attribute name="title">
                                <xsl:call-template name="localizedMessage">
                                    <xsl:with-param
                        name="id"
                        select="'registerowner'" />
                                </xsl:call-template>
                            </xsl:attribute>
                </ds-logo-title>
                <hr />
                <p>
                    <a
                        href="mailto:kodeliste@kds.dk?subject=Angående%20kodeliste"
                        target="_blank">
                        <xsl:copy-of select="$mailIcon" />
                        <xsl:call-template name="localizedMessage">
                            <xsl:with-param
                                name="id"
                                select="'registeremailmessage'" />
                        </xsl:call-template>
                    </a>
                </p>
                <p>
                    <xsl:call-template name="localizedMessage">
                        <xsl:with-param
                            name="id"
                            select="'registergdprmessage'" />
                    </xsl:call-template>
                </p>
            </div>
        </footer>
    </xsl:template>

</xsl:stylesheet>