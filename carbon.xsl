<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:carbon="http://wso2.org/projects/carbon/carbon.xml" xmlns="http://wso2.org/projects/carbon/carbon.xml" exclude-result-prefixes="carbon xs">
   <xsl:param name="hostname" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="keystore" as="xs:string" required="yes"/>
   <xsl:param name="alias" as="xs:string" required="yes"/>

   <xsl:output method="xml" encoding="ISO-8859-1" omit-xml-declaration="no" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server">
      <xsl:copy>
         <xsl:apply-templates />
         <xsl:if test="not(carbon:HostName)">
            <HostName><xsl:value-of select="$hostname"/></HostName>
         </xsl:if>
         <xsl:if test="not(carbon:MgtHostName)">
            <MgtHostName><xsl:value-of select="$hostname"/></MgtHostName>
         </xsl:if>
         <xsl:if test="not(carbon:EnableEmailUserName)">
            <EnableEmailUserName>true</EnableEmailUserName>
         </xsl:if>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:HostName">
      <xsl:copy><xsl:value-of select="$hostname"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:MgtHostName">
      <xsl:copy><xsl:value-of select="$hostname"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:EnableEmailUserName">
      <xsl:copy>true</xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Password|carbon:KeyPassword">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:Security/carbon:KeyStore/carbon:Location">
      <xsl:copy><xsl:value-of select="$keystore"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:Security/carbon:KeyStore/carbon:KeyAlias">
      <xsl:copy><xsl:value-of select="$alias"/></xsl:copy>
   </xsl:template>

   <xsl:template match="carbon:Server/carbon:Axis2Config/carbon:HideAdminServiceWSDLs">
      <xsl:copy>false</xsl:copy>
   </xsl:template>
</xsl:stylesheet>
