<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:carbon="http://wso2.org/projects/carbon/carbon.xml" xmlns="http://wso2.org/projects/carbon/carbon.xml" exclude-result-prefixes="carbon xs">
   <xsl:param name="hostname" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="keystore" as="xs:string" required="yes"/>
   <xsl:param name="alias" as="xs:string" required="yes"/>

   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:ServerKey">
      <xsl:copy-of select="." />
      <HostName><xsl:value-of select="$hostname"/></HostName>
      <MgtHostName><xsl:value-of select="$hostname"/></MgtHostName>
   </xsl:template>

   <xsl:template match="carbon:Password|carbon:KeyPassword">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:KeyStore/carbon:Location">
      <!--xsl:copy>${carbon.home}<xsl:value-of select="$keystore"/></xsl:copy-->
      <xsl:copy><xsl:value-of select="$keystore"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:KeyStore/carbon:KeyAlias">
      <xsl:copy><xsl:value-of select="$alias"/></xsl:copy>
   </xsl:template>
</xsl:stylesheet>
