<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
   <xsl:param name="hostname" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="thriftserver" as="xs:string" required="yes"/>

   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="Password">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>

   <xsl:template match="APIGateway/Environments/Environment/GatewayEndpoint">
      <xsl:copy>http:\\<xsl:value-of select="$hostname"/>:${http.nio.port},https:\\<xsl:value-of select="$hostname"/>:${https.nio.port}</xsl:copy>
   </xsl:template>

   <xsl:template match="APIKeyValidator/ThriftServerPort">
      <xsl:copy-of select="." />
      <ThriftServerHost><xsl:value-of select="$thriftserver"/></ThriftServerHost>
   </xsl:template>
</xsl:stylesheet>
