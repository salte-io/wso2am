<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="keystore" as="xs:string" required="yes"/>
   
   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="Password|KeyPassword">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>

   <xsl:template match="KeyStore/Location">
      <xsl:copy><xsl:value-of select="$keystore"/></xsl:copy>
   </xsl:template>

   <xsl:template match="transportSender[@name='https']/parameter[@name='truststore']">
      <!--xsl:copy-of select="." /-->
      <xsl:apply-templates />
      <parameter name="HostnameVerifier">DefaultAndLocalhost</parameter>
   </xsl:template>
</xsl:stylesheet>
