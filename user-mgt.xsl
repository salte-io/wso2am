<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:param name="userds" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>

   <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" />
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

   <xsl:template match="UserStoreManager[@class='org.wso2.carbon.user.core.jdbc.JDBCUserStoreManager']/Property[@name='UsernameJavaRegEx']">
      <xsl:copy><xsl:copy-of select="@*" />^[_A-Za-z0-9-\+]+(\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\.[A-Za-z0-9]+)*(\.[A-Za-z]{2,})$</xsl:copy>
   </xsl:template>

   <xsl:template match="UserStoreManager[@class='org.wso2.carbon.user.core.jdbc.JDBCUserStoreManager']/Property[@name='IsEmailUserName']">
      <xsl:copy><xsl:copy-of select="@*" />true</xsl:copy>
   </xsl:template>

   <xsl:template match="AdminUser/UserName">
      <xsl:copy>admin@wso2.com</xsl:copy>
   </xsl:template>
</xsl:stylesheet>
