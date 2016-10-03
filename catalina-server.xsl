<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="proxyport" as="xs:integer"/>

   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@keystorePass[parent::Connector]">
      <xsl:attribute name="keystorePass">
         <xsl:value-of select="$password"/>
      </xsl:attribute>
   </xsl:template>

   <xsl:template match="/Server/Service/Connector[@port='9443']">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
         <xsl:choose>
            <xsl:when test="$proxyport">
               <xsl:attribute name="proxyPort">
                  <xsl:value-of select="$proxyport" />
               </xsl:attribute>
            </xsl:when>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
