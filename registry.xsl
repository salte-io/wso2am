<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
   <xsl:param name="sqlhost" as="xs:string" required="yes"/>
   <xsl:param name="sqlport" as="xs:string" required="yes"/>
   <xsl:param name="regds" as="xs:string" required="yes"/>
   <xsl:param name="regdb" as="xs:string" required="yes"/>
   <xsl:param name="dbuser" as="xs:string" required="yes"/>

   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="wso2registry/dbConfig[@name='wso2registry']">
      <xsl:copy-of select="." />
      <xsl:call-template name="gen-datasource" />
   </xsl:template>

   <xsl:template name="gen-datasource">
      <dbConfig name="govregistry">
         <dataSource><xsl:value-of select="$regds"/></dataSource>
      </dbConfig>

      <remoteInstance url="https://localhost:9443/registry">
         <id>gov</id>
         <cacheId><xsl:value-of select="concat(concat(concat(concat(concat(concat($dbuser, '@jdbc://mysql://'), $sqlhost), ':'), $sqlport), '/'), $regdb)"/></cacheId>
         <dbConfig>govregistry</dbConfig>
         <readOnly>false</readOnly>
         <enableCache>true</enableCache>
         <registryRoot>/</registryRoot>
      </remoteInstance>

      <mount path="/_system/config" overwrite="true">
         <instanceId>gov</instanceId>
         <targetPath>/_system/config</targetPath>
      </mount>
   </xsl:template>
</xsl:stylesheet>
