#!/bin/bash
set -eo pipefail

if [ ! -f "/opt/wso2am/repository/conf/initialized" ]; then
  cd /opt/wso2am/repository/resources/security

  if [ -z "$DATABASE_PASSWORD_FILE" ] && [ -f "$DATABASE_PASSWORD_FILE" ]; then
    export DATABASE_PASSWORD=$(cat $DATABASE_PASSWORD_FILE)
  fi

  if [ -z "$PRIVATE_KEY_PASSWORD_FILE" ] && [ -f "$PRIVATE_KEY_PASSWORD_FILE" ]; then
    export PRIVATE_KEY_PASSWORD=$(cat $PRIVATE_KEY_PASSWORD_FILE)
  fi


  if [ -z "$ADMIN_PASSWORD_FILE" ] && [ -f "$ADMIN_PASSWORD_FILE" ]; then
    export ADMIN_PASSWORD=$(cat $ADMIN_PASSWORD_FILE)
  fi

  # Prepare Keystore
  openssl pkcs12 -export -in $PUBLIC_CERTIFICATE -inkey $PRIVATE_KEY -out wso2carbon.p12 -name wso2carbon -passout pass:$PRIVATE_KEY_PASSWORD
  keytool -delete -alias wso2carbon -keystore wso2carbon.jks -storepass wso2carbon
  keytool -importkeystore -noprompt -deststorepass wso2carbon -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore wso2carbon.jks -srckeystore wso2carbon.p12 -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD -alias wso2carbon
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore wso2carbon.jks -storepass wso2carbon

  # Prepare Client Truststore
  keytool -delete -alias wso2carbon -keystore client-truststore.jks -storepass wso2carbon
  keytool -importcert -noprompt -alias wso2carbon -keystore client-truststore.jks -storepass wso2carbon -file $PUBLIC_CERTIFICATE
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore client-truststore.jks -storepass wso2carbon
  keytool -importcert -noprompt -keystore client-truststore.jks -storepass $PRIVATE_KEY_PASSWORD -file $CA_CERTIFICATE_BUNDLE
  rm wso2carbon.p12
  
  # Update Configuration Files
  saxonb-xslt -s:/opt/wso2am/repository/conf/axis2/axis2.xml -xsl:/tmp/axis2.xsl -o:/opt/wso2am/repository/conf/axis2/axis2.xml password=$PRIVATE_KEY_PASSWORD keystore=/opt/wso2am/repository/resources/security/wso2carbon.jks
  saxonb-xslt -s:/opt/wso2am/repository/conf/carbon.xml -xsl:/tmp/carbon.xsl -o:/opt/wso2am/repository/conf/carbon.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD keystore=/opt/wso2am/repository/resources/security/wso2carbon.jks alias=wso2carbon offset=$OFFSET
  saxonb-xslt -s:/opt/wso2am/repository/conf/identity/identity.xml -xsl:/tmp/identity.xsl -o:/opt/wso2am/repository/conf/identity/identity.xml hostname=$EXTERNAL_HOSTNAME offset=$OFFSET
  saxonb-xslt -s:/opt/wso2am/repository/conf/user-mgt.xml -xsl:/tmp/user-mgt.xsl -o:/opt/wso2am/repository/conf/user-mgt.xml userds=jdbc/WSO2UM_DB password=$ADMIN_PASSWORD
  saxonb-xslt -s:/opt/wso2am/repository/conf/registry.xml -xsl:/tmp/registry.xsl -o:/opt/wso2am/repository/conf/registry.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT regds=jdbc/WSO2REG_DB regdb=regdb dbuser=$DATABASE_USER
  saxonb-xslt -s:/opt/wso2am/repository/conf/datasources/master-datasources.xml -xsl:/tmp/master-datasources.xsl -o:/opt/wso2am/repository/conf/datasources/master-datasources.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT apidb=apimgtdb userdb=userdb userds=jdbc/WSO2UM_DB regdb=regdb regds=jdbc/WSO2REG_DB dbuser=$DATABASE_USER dbpassword=$DATABASE_PASSWORD
  saxonb-xslt -s:/opt/wso2am/repository/conf/data-bridge/data-bridge-config.xml -xsl:/tmp/data-bridge-config.xsl -o:/opt/wso2am/repository/conf/data-bridge/data-bridge-config.xml password=$PRIVATE_KEY_PASSWORD

  if [ -z "$PROXY_PORT" ] && ! [[ $PROXY_PORT =~ ^[0-9]+$ ]]; then
    echo "When specified, PROXY_PORT must be numeric."
    exit 1
  elif [ -z "$SSL_PROXY_PORT" ] && ! [[ $SSL_PROXY_PORT =~ ^[0-9]+$ ]]; then
    echo "When specified, SSL_PROXY_PORT must be numeric."
    exit 1
  elif [ -z "$PROXY_PORT" ] && [ -z "$SSL_PROXY_PORT" ]; then
    saxonb-xslt -s:/opt/wso2am/repository/conf/api-manager.xml -xsl:/tmp/api-manager.xsl -o:/opt/wso2am/repository/conf/api-manager.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD jwtexpiry=$JWT_EXPIRY thriftserver=localhost proxyport=$PROXY_PORT sslproxyport=$SSL_PROXY_PORT topicconnectionfactory="amqp://admin!wso2.com!carbon.super:$ADMIN_PASSWORD@clientid/carbon?brokerlist='tcp://localhost:5682'"
    saxonb-xslt -s:/opt/wso2am/repository/conf/tomcat/catalina-server.xml -xsl:/tmp/catalina-server.xsl -o:/opt/wso2am/repository/conf/tomcat/catalina-server.xml password=$PRIVATE_KEY_PASSWORD sslproxyport=$SSL_PROXY_PORT
  else
    saxonb-xslt -s:/opt/wso2am/repository/conf/api-manager.xml -xsl:/tmp/api-manager.xsl -o:/opt/wso2am/repository/conf/api-manager.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD jwtexpiry=$JWT_EXPIRY thriftserver=localhost topicconnectionfactory="amqp://admin!wso2.com!carbon.super:$ADMIN_PASSWORD@clientid/carbon?brokerlist='tcp://localhost:5682'"
    saxonb-xslt -s:/opt/wso2am/repository/conf/tomcat/catalina-server.xml -xsl:/tmp/catalina-server.xsl -o:/opt/wso2am/repository/conf/tomcat/catalina-server.xml password=$PRIVATE_KEY_PASSWORD
  fi

  # Indicate Container Initialization Complete
  touch /opt/wso2am/repository/conf/initialized


  # Clean-up Configuration File Transformation Scripts
  rm /tmp/*.xsl

  # Clean-up Security-Related Environment Variables
  unset DATABASE_PASSWORD
  unset PRIVATE_KEY_PASSWORD
  unset ADMIN_PASSWORD

  # Sleep to give other containers we're dependent upon a chance to complete their initialization.
  if [ -z "$DELAY" ] && [[ $DELAY =~ ^[0-9]+$ ]]; then
    sleep $DELAY
  fi
fi

exec "/opt/wso2am/bin/wso2server.sh"
