<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
   <xsl:param name="hostname" as="xs:string" required="yes"/>
   <xsl:param name="password" as="xs:string" required="yes"/>
   <xsl:param name="jwtexpiry" as="xs:integer" required="yes"/>
   <xsl:param name="thriftserver" as="xs:string" required="yes"/>
   <xsl:param name="sslproxyport" as="xs:integer" required="no">0</xsl:param>
   <xsl:param name="proxyport" as="xs:integer" required="no">0</xsl:param>

   <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" cdata-section-elements="connectionfactory.TopicConnectionFactory"/>
   <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>

   <xsl:template match="Password">
      <xsl:copy><xsl:value-of select="$password"/></xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIKeyValidator">
      <xsl:copy>
         <xsl:apply-templates />
         <xsl:if test="not(JWTExpiryTime)">
            <JWTExpiryTime><xsl:value-of select="$jwtexpiry"/></JWTExpiryTime>
         </xsl:if>
         <xsl:if test="not(ThriftServerHost)">
            <ThriftServerHost><xsl:value-of select="$thriftserver"/></ThriftServerHost>
         </xsl:if>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/AuthManager/ServerURL">
      <xsl:call-template name="ProcessServerURL"/>
   </xsl:template>

   <xsl:template match="APIManager/APIGateway/Environments/Environment/ServerURL">
      <xsl:call-template name="ProcessServerURL"/>
   </xsl:template>

   <xsl:template match="APIManager/APIGateway/Environments/Environment/GatewayEndpoint">
      <xsl:copy>
         <xsl:choose> 
            <xsl:when test="$proxyport">http://<xsl:value-of select="$hostname"/>:<xsl:value-of select="$proxyport"/>,</xsl:when>
            <xsl:otherwise>http://<xsl:value-of select="$hostname"/>:${http.nio.port},</xsl:otherwise>
         </xsl:choose>
         <xsl:choose> 
            <xsl:when test="$sslproxyport">https://<xsl:value-of select="$hostname"/>:<xsl:value-of select="$sslproxyport"/></xsl:when>
            <xsl:otherwise>https://<xsl:value-of select="$hostname"/>:${https.nio.port}</xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>

   <!-- The following two templates must disable the token cache so the JWTExpiryTime will take affect.
        Instead, I could have made sure the setting for JWTClaimCacheExpiry and/or TokenCacheExpiry
        were setup correctly.  I need to dig into this a little more.  All I know for sure is if I
        don't do one of the previously mentioned things, the JWT sent to the back-end is already
        one minute past expiration the instant it is created.  Looking at WSO2's code, I can see that
        this is probably the result of a bug where the token expiry is multiplied by a class-level
        variable's default value, which is negative one, if one of these settings aren't configured
        as described. -->
   <xsl:template match="APIManager/CacheConfigurations/EnableGatewayTokenCache">
      <xsl:copy>false</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/CacheConfigurations/EnableKeyManagerTokenCache">
      <xsl:copy>false</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIKeyValidator/ServerURL">
      <xsl:call-template name="ProcessServerURL"/>
   </xsl:template>

   <xsl:template match="APIManager/APIValidator/JWTExpiryTime">
      <xsl:copy><xsl:value-of select="$jwtexpiry"/></xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIKeyValidator/ThriftServerHost">
      <xsl:copy><xsl:value-of select="$thriftserver"/></xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIStore">
      <xsl:copy>
         <xsl:apply-templates />
         <xsl:if test="not(GroupingExtractor)">
            <GroupingExtractor>org.wso2.carbon.apimgt.impl.DefaultGroupIDExtractorImpl</GroupingExtractor>
         </xsl:if>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIStore/GroupingExtractor">
     <xsl:copy>org.wso2.carbon.apimgt.impl.DefaultGroupIDExtractorImpl</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/JWTConfiguration">
      <xsl:copy>
         <xsl:apply-templates />
         <xsl:if test="not(EnableJWTGeneration)">
            <EnableJWTGeneration>true</EnableJWTGeneration>
         </xsl:if>
         <xsl:if test="not(ClaimsRetrieverImplClass)">
            <ClaimsRetrieverImplClass>org.wso2.carbon.apimgt.impl.token.DefaultClaimsRetriever</ClaimsRetrieverImplClass>
         </xsl:if>
         <xsl:if test="not(ConsumerDialectURI)">
            <ConsumerDialectURI>http://wso2.org/claims</ConsumerDialectURI>
         </xsl:if>
         <xsl:if test="not(SignatureAlgorithm)">
            <SignatureAlgorithm>SHA256withRSA</SignatureAlgorithm>
         </xsl:if>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/JWTConfiguration/EnableJWTGeneration">
      <xsl:copy>true</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIKeyValidator/KeyValidatorClientType">
      <xsl:copy>WSClient</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/JWTConfiguration/ClaimsRetrieverImplClass">
      <xsl:copy>org.wso2.carbon.apimgt.impl.token.DefaultClaimsRetriever</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/JWTConfiguration/ConsumerDialectURI">
      <xsl:copy>http://wso2.org/claims</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/JWTConfiguration/SignatureAlgorithm">
      <xsl:copy>SHA256withRSA</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/ThrottlingConfigurations/DataPublisher/Username">
      <xsl:copy>admin@wso2.com@carbon.super</xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIStore/URL">
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="$sslproxyport">https://<xsl:value-of select="$hostname"/>:<xsl:value-of select="$sslproxyport"/>/store</xsl:when>
            <xsl:otherwise>https://<xsl:value-of select="$hostname"/>:${mgt.transport.https.port}/store</xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="APIManager/APIStore/ServerURL">
      <xsl:call-template name="ProcessServerURL"/>
   </xsl:template>

   <xsl:template match="APIManager/APIPublisher/URL">
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="$sslproxyport">https://<xsl:value-of select="$hostname"/>:<xsl:value-of select="$sslproxyport"/>/publisher</xsl:when>
            <xsl:otherwise>https://<xsl:value-of select="$hostname"/>:${mgt.transport.https.port}/publisher</xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>

   <xsl:template name="ProcessServerURL">
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="$sslproxyport">https://<xsl:value-of select="$hostname"/>:<xsl:value-of select="$sslproxyport"/>${carbon.context}services/</xsl:when>
            <xsl:otherwise>https://<xsl:value-of select="$hostname"/>:${mgt.transport.https.port}${carbon.context}services/</xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
