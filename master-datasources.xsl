<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
   <xsl:param name="sqlhost" as="xs:string" required="yes"/>
   <xsl:param name="sqlport" as="xs:string" required="yes"/>
   <xsl:param name="apidb" as="xs:string" required="yes"/>
   <xsl:param name="userdb" as="xs:string" required="yes"/>
   <xsl:param name="userds" as="xs:string" required="yes"/>
   <xsl:param name="regdb" as="xs:string" required="yes"/>
   <xsl:param name="regds" as="xs:string" required="yes"/>
   <xsl:param name="dbuser" as="xs:string" required="yes"/>
   <xsl:param name="dbpassword" as="xs:string" required="yes"/>

   <xsl:variable name="driver" select="'com.mysql.jdbc.Driver'" />
   
   <xsl:output method="xml" indent="yes" />
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        High-level control for datasource processing.
        *********************************************************************-->
   <xsl:template match="datasources">
      <xsl:copy>
         <xsl:apply-templates />
         <xsl:if test="not(datasource[name='WSO2AM_DB'])">
            <xsl:call-template name="gen-datasource">
               <xsl:with-param name="dsname" select="'WSO2AM_DB'" />
               <xsl:with-param name="dbname" select="$apidb" />
               <xsl:with-param name="jnname" select="'jdbc/WSO2AM_DB'" />
            </xsl:call-template>
         </xsl:if>
         <xsl:if test="not(datasource[name='WSO2UM_DB'])">
            <xsl:call-template name="gen-datasource">
               <xsl:with-param name="dsname" select="'WSO2UM_DB'" />
               <xsl:with-param name="dbname" select="$userdb" />
               <xsl:with-param name="jnname" select="$userds" />
            </xsl:call-template>
         </xsl:if>
         <xsl:if test="not(datasource[name='WSO2REG_DB'])">
            <xsl:call-template name="gen-datasource">
               <xsl:with-param name="dsname" select="'WSO2REG_DB'" />
               <xsl:with-param name="dbname" select="$regdb" />
               <xsl:with-param name="jnname" select="$regds" />
            </xsl:call-template>
         </xsl:if>
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        This section will update the database driver connection string for an
        existing API Management database entry if one exists.
        *********************************************************************-->
   <xsl:template match="datasource[name='WSO2AM_DB']/definition/configuration/url">
      <xsl:copy>
         <xsl:value-of select="concat(concat(concat(concat(concat(concat('jdbc:mysql://', $sqlhost), ':'), $sqlport), '/'), $apidb), '?autoReconnect=true&amp;relaxAutoCommit=true&amp;UseSSL=false')"/>
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        This section will update the database driver connection string for an
        existing User Management database entry if one exists.
        *********************************************************************-->
   <xsl:template match="datasource[name='WSO2UM_DB']/definition/configuration/url">
      <xsl:copy>
         <xsl:value-of select="concat(concat(concat(concat(concat(concat('jdbc:mysql://', $sqlhost), ':'), $sqlport), '/'), $userdb), '?autoReconnect=true&amp;relaxAutoCommit=true&amp;UseSSL=false')"/>
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        This section will update the database driver connection string for an
        existing Registry database entry if one exists.
        *********************************************************************-->
   <xsl:template match="datasource[name='WSO2REG_DB']/definition/configuration/url">
      <xsl:copy>
         <xsl:value-of select="concat(concat(concat(concat(concat(concat('jdbc:mysql://', $sqlhost), ':'), $sqlport), '/'), $regdb), '?autoReconnect=true&amp;relaxAutoCommit=true&amp;UseSSL=false')"/>
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        This section will update existing database entries for username,
        password, and database driver.
        *********************************************************************-->
   <xsl:template match="datasource[name='WSO2AM_DB' or name='WSO2UM_DB' or name='WSO2REG_DB']/definition/configuration/username">
      <xsl:copy>
         <xsl:value-of select="$dbuser"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="datasource[name='WSO2AM_DB' or name='WSO2UM_DB' or name='WSO2REG_DB']/definition/configuration/password">
      <xsl:copy>
         <xsl:value-of select="$dbpassword"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="datasource[name='WSO2AM_DB' or name='WSO2UM_DB' or name='WSO2REG_DB']/definition/configuration/driverClassName">
      <xsl:copy>
         <xsl:value-of select="$driver"/>
      </xsl:copy>
   </xsl:template>

   <!-- ************************************************************************
        This section is called explicitely for each of the three required
        datasouces if they don't already exist.
        *********************************************************************-->
   <xsl:template name="gen-datasource">
      <xsl:param name="dsname" />
      <xsl:param name="dbname" />
      <xsl:param name="jnname" />

      <datasource>
         <name><xsl:value-of select="$dsname" /></name>
         <description>Datasource generated by build process.</description>
         <jndiConfig>
            <name><xsl:value-of select="$jnname" /></name>
         </jndiConfig>
         <definition type="RDBMS">
            <configuration>
               <url><xsl:value-of select="concat(concat(concat(concat(concat(concat('jdbc:mysql://', $sqlhost), ':'), $sqlport), '/'), $dbname), '?autoReconnect=true&amp;relaxAutoCommit=true')"/></url>
               <username><xsl:value-of select="$dbuser" /></username>
               <password><xsl:value-of select="$dbpassword" /></password>
               <driverClassName><xsl:value-of select="$driver" /></driverClassName>
               <maxActive>50</maxActive>
               <maxWait>60000</maxWait>
               <testOnBorrow>true</testOnBorrow>
               <validationQuery>SELECT 1</validationQuery>
               <validationInterval>30000</validationInterval>
            </configuration>
         </definition>
      </datasource>
   </xsl:template>
</xsl:stylesheet>
