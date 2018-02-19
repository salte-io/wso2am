<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="keystore" as="xs:string" required="yes"/>

   <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="keyStoreLocation">
      <xsl:copy><xsl:value-of select="$keystore"/></xsl:copy>
   </xsl:template>

   <xsl:template match="keyStorePassword">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>
</xsl:stylesheet>