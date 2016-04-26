<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:carbon="http://wso2.org/projects/carbon/carbon.xml" xmlns="http://wso2.org/projects/carbon/carbon.xml"  exclude-result-prefixes="carbon xs">
   <xsl:param name="hostname" as="xs:string" required="yes"/>
   
   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:OpenIDSkipUserConsent">
      <xsl:copy>true</xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:SkipUserConsent">
      <xsl:copy>true</xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:OpenIDServerUrl">
      <xsl:copy>https://<xsl:value-of select="$hostname"/>:9443/openidserver</xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:OpenIDUserPattern">
      <xsl:copy>https://<xsl:value-of select="$hostname"/>:9443/openid/</xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:IDTokenIssuerID">
      <xsl:copy>https://<xsl:value-of select="$hostname"/>:9334/oauth2endpoints/token</xsl:copy>
   </xsl:template>
</xsl:stylesheet>
