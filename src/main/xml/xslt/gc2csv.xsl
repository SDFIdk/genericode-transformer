<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
    Stylesheet that converts a genericode file to a CSV file.
    -->

    <xsl:output
        method="text"
        encoding="UTF-8" />
    
	<!-- See https://www.w3.org/TR/xslt-30/#element-mode and https://www.w3.org/TR/xslt-30/#built-in-templates-shallow-skip -->
    <xsl:mode on-no-match="shallow-skip" />

    <xsl:template match="/gc:CodeList">
        <!-- Write header -->
        <!-- No white spaces can be present in @Id, so no surrounding with quotes needed -->
        <xsl:value-of select="string-join(ColumnSet/Column/@Id, ',') || '&#13;&#10;'" />

        <!-- Write values -->
        <xsl:apply-templates select="SimpleCodeList/Row" />
    </xsl:template>

    <!-- Assumption: The order of the values is the same as the order of the declared columns and
    an undefined value is encoded as an empty `Value` element. -->
    <xsl:template match="Row">
        <xsl:value-of select="string-join(for $v in Value return '&#34;' || replace($v/SimpleValue, '&#34;', '&#34;&#34;') || '&#34;', ',') || '&#13;&#10;'" />
    </xsl:template>

</xsl:stylesheet>