<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:param name="userds" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>

   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="UserManager/Realm/Configuration/Property[@name='dataSource']">
      <xsl:copy><xsl:copy-of select="@*" /><xsl:value-of select="$userds"/></xsl:copy>
   </xsl:template>

   <xsl:template match="Password">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>
</xsl:stylesheet>
