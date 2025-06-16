<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <!-- 
    Stylesheet with common functionality for generating HTML pages,
    to be included in other stylesheets that generate HTML pages.
    -->
    
    <xsl:include href="common-l10n.xsl" />

    <xsl:variable
        name="designsystemVersion"
        select="'8'" />

    <xsl:variable
        name="designsystemUrl"
        select="'https://cdn.dataforsyningen.dk/assets/designsystem/v' || $designsystemVersion" />
        
    <xsl:variable
        name="exitSiteIcon"
        select="document($designsystemUrl || '/icons/exitsite.svg')" />

    <xsl:variable
        name="mailIcon"
        select="document($designsystemUrl || '/icons/mail.svg')" />
		
	<xsl:variable 
		name="feedIcon"
		select="document($designsystemUrl || '/icons/some-feed.svg')" />

    <!-- Prerequisite: DSLogoTitle has been imported from designsystem.js in the stylesheet that includes this stylesheet -->
    <xsl:template name="generateDsLogoTitle">
        <ds-logo-title>
            <xsl:attribute name="title">
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="'registername'" />
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="byline">
                <xsl:call-template name="localizedMessage">
                    <xsl:with-param
                        name="id"
                        select="'registerowner'" />
                </xsl:call-template>
            </xsl:attribute>
        </ds-logo-title>
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
                        href="mailto:kodeliste@kds.dk"
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
                            select="'registerscopemessage'" />
                    </xsl:call-template>
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
	
	<xsl:template name="feedLink">
		<a href="./feed.atom">
			<xsl:call-template name="localizedMessage">
				<xsl:with-param
					name="id"
					select="'feedtextlink'" />
			</xsl:call-template>
            <xsl:copy-of select="$feedIcon" />
		</a>
	</xsl:template>

</xsl:stylesheet>