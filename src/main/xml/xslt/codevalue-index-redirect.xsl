<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--
    method: must be xhtml, because the resulting files will be checked again in step transform-and-store-codelists
    html-version: see https://www.saxonica.com/documentation12/index.html#!xsl-elements/output and https://www.w3.org/TR/xslt-30/
    include-content-type: meta-tag with Content-Type is not necessary, because <meta charset="utf-8"/> is already present
    omit-xml-declaration: if not present (default: no), https://validator.w3.org will give an error: "XML processing instructions are not supported in HTML"
    -->
    <xsl:output method="xhtml"
                html-version="5.0"
                encoding="utf-8"
                include-content-type="no"
                omit-xml-declaration="yes"
                indent="yes"/>
    <xsl:param name="code-list-register-uri-latest-html"
               required="true"/>
    <xsl:template name="main">
        <xsl:document>
            <html lang="en">
                <head>
                    <meta charset="utf-8"/>
                    <title>Redirecting to <xsl:value-of select="$code-list-register-uri-latest-html"/>
                    </title>
                    <meta http-equiv="refresh"
                          content="0; URL={$code-list-register-uri-latest-html}"/>
                    <link rel="canonical"
                          href="{$code-list-register-uri-latest-html}"/>
                </head>
                <body>
                    <p>If you are not automatically redirected, <a href="{$code-list-register-uri-latest-html}">click here</a>
                    </p>
                </body>
            </html>
        </xsl:document>
    </xsl:template>
</xsl:stylesheet>
