<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
    Stylesheet with common functionality for working with files
    that follow a naming convention based on semantic versoning,
    to be included in other stylesheets.
    -->
            
    <!-- E.g. for for string v1.2.3.codelist.html
    capturing sub-expression 1 is 1.2.3
    capturing sub-expression 2 is 1
    capturing sub-expression 3 is 2
    capturing sub-expression 4 is 3
     -->
    <xsl:variable
        name="regexNameWithVersion"
        select="'^v(([0-9]+)\.([0-9]+)\.([0-9]+))\..*'" />

</xsl:stylesheet>