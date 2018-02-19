#!/bin/bash
set -eo pipefail

REPOSITORY_ROOT=/opt/wso2am/repository
CONFIGURATION_ROOT=$REPOSITORY_ROOT/conf

if [ ! -f "$REPOSITORY_ROOT/conf/initialized" ]; then
  KEYSTORE_ROOT=$REPOSITORY_ROOT/resources/security
  KEYSTORE_FILENAME=wso2carbon.jks
  CLIENT_KEYSTORE_FILENAME=client-truststore.jks
  KEYSTORE_ENTRY=wso2carbon
  KEYSTORE_DEFAULT_PASSWORD=wso2carbon

  cd $KEYSTORE_ROOT

  if [ ! -z "$DATABASE_PASSWORD_FILE" ] && [ -f "$DATABASE_PASSWORD_FILE" ]; then
    export DATABASE_PASSWORD=$(cat $DATABASE_PASSWORD_FILE)
  fi

  if [ ! -z "$PRIVATE_KEY_PASSWORD_FILE" ] && [ -f "$PRIVATE_KEY_PASSWORD_FILE" ]; then
    export PRIVATE_KEY_PASSWORD=$(cat $PRIVATE_KEY_PASSWORD_FILE)
  fi


  if [ ! -z "$ADMIN_PASSWORD_FILE" ] && [ -f "$ADMIN_PASSWORD_FILE" ]; then
    export ADMIN_PASSWORD=$(cat $ADMIN_PASSWORD_FILE)
  fi

  # Prepare Keystore
  openssl pkcs12 -export -in $PUBLIC_CERTIFICATE -inkey $PRIVATE_KEY -out wso2carbon.p12 -name $KEYSTORE_ENTRY -passout pass:$PRIVATE_KEY_PASSWORD
  keytool -delete -alias $KEYSTORE_ENTRY -keystore $KEYSTORE_FILENAME -storepass $KEYSTORE_DEFAULT_PASSWORD
  keytool -importkeystore -noprompt -deststorepass $KEYSTORE_DEFAULT_PASSWORD -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore $KEYSTORE_FILENAME -srckeystore wso2carbon.p12 -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD -alias $KEYSTORE_ENTRY
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore $KEYSTORE_FILENAME -storepass $KEYSTORE_DEFAULT_PASSWORD

  # Prepare Client Truststore
  keytool -delete -alias $KEYSTORE_ENTRY -keystore $CLIENT_KEYSTORE_FILENAME -storepass $KEYSTORE_DEFAULT_PASSWORD
  keytool -importcert -noprompt -alias $KEYSTORE_ENTRY -keystore $CLIENT_KEYSTORE_FILENAME -storepass $KEYSTORE_DEFAULT_PASSWORD -file $PUBLIC_CERTIFICATE
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore $CLIENT_KEYSTORE_FILENAME -storepass $KEYSTORE_DEFAULT_PASSWORD
  keytool -importcert -noprompt -keystore $CLIENT_KEYSTORE_FILENAME -storepass $PRIVATE_KEY_PASSWORD -file $CA_CERTIFICATE_BUNDLE
  rm wso2carbon.p12
  
  # Update Configuration Files
  saxonb-xslt -s:$CONFIGURATION_ROOT/axis2/axis2.xml -xsl:/tmp/axis2.xsl -o:$CONFIGURATION_ROOT/axis2/axis2.xml password=$PRIVATE_KEY_PASSWORD keystore=$KEYSTORE_ROOT/$KEYSTORE_FILENAME
  saxonb-xslt -s:$CONFIGURATION_ROOT/carbon.xml -xsl:/tmp/carbon.xsl -o:$CONFIGURATION_ROOT/carbon.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD keystore=$KEYSTORE_ROOT/$KEYSTORE_FILENAME alias=wso2carbon offset=$OFFSET
  saxonb-xslt -s:$CONFIGURATION_ROOT/identity/identity.xml -xsl:/tmp/identity.xsl -o:$CONFIGURATION_ROOT/identity/identity.xml hostname=$EXTERNAL_HOSTNAME offset=$OFFSET
  saxonb-xslt -s:$CONFIGURATION_ROOT/user-mgt.xml -xsl:/tmp/user-mgt.xsl -o:$CONFIGURATION_ROOT/user-mgt.xml userds=jdbc/WSO2UM_DB password=$ADMIN_PASSWORD
  saxonb-xslt -s:$CONFIGURATION_ROOT/registry.xml -xsl:/tmp/registry.xsl -o:$CONFIGURATION_ROOT/registry.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT regds=jdbc/WSO2REG_DB regdb=regdb dbuser=$DATABASE_USER
  saxonb-xslt -s:$CONFIGURATION_ROOT/datasources/master-datasources.xml -xsl:/tmp/master-datasources.xsl -o:$CONFIGURATION_ROOT/datasources/master-datasources.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT apidb=apimgtdb userdb=userdb userds=jdbc/WSO2UM_DB regdb=regdb regds=jdbc/WSO2REG_DB dbuser=$DATABASE_USER dbpassword=$DATABASE_PASSWORD
  saxonb-xslt -s:$CONFIGURATION_ROOT/data-bridge/data-bridge-config.xml -xsl:/tmp/data-bridge-config.xsl -o:$CONFIGURATION_ROOT/data-bridge/data-bridge-config.xml password=$PRIVATE_KEY_PASSWORD keystore=$KEYSTORE_ROOT/$KEYSTORE_FILENAME

  set +H
  TOPIC_CONNECTION_FACTORY="amqp://admin!wso2.com!carbon.super:\${jms.password}@clientid/carbon?brokerlist='\${jms.url}'"
  set -H
  if [ ! -z "$PROXY_PORT" ] && ! [[ $PROXY_PORT =~ ^[0-9]+$ ]]; then
    echo "When specified, PROXY_PORT must be numeric."
    exit 1
  elif [ ! -z "$SSL_PROXY_PORT" ] && ! [[ $SSL_PROXY_PORT =~ ^[0-9]+$ ]]; then
    echo "When specified, SSL_PROXY_PORT must be numeric."
    exit 1
  elif [ ! -z "$PROXY_PORT" ] && [ ! -z "$SSL_PROXY_PORT" ]; then
    saxonb-xslt -s:$CONFIGURATION_ROOT/api-manager.xml -xsl:/tmp/api-manager.xsl -o:$CONFIGURATION_ROOT/api-manager.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD jwtexpiry=$JWT_EXPIRY thriftserver=localhost proxyport=$PROXY_PORT sslproxyport=$SSL_PROXY_PORT topicconnectionfactory=$TOPIC_CONNECTION_FACTORY
    saxonb-xslt -s:$CONFIGURATION_ROOT/tomcat/catalina-server.xml -xsl:/tmp/catalina-server.xsl -o:$CONFIGURATION_ROOT/tomcat/catalina-server.xml password=$PRIVATE_KEY_PASSWORD sslproxyport=$SSL_PROXY_PORT
  else
    saxonb-xslt -s:$CONFIGURATION_ROOT/api-manager.xml -xsl:/tmp/api-manager.xsl -o:$CONFIGURATION_ROOT/api-manager.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD jwtexpiry=$JWT_EXPIRY thriftserver=localhost topicconnectionfactory=$TOPIC_CONNECTION_FACTORY
    saxonb-xslt -s:$CONFIGURATION_ROOT/tomcat/catalina-server.xml -xsl:/tmp/catalina-server.xsl -o:$CONFIGURATION_ROOT/tomcat/catalina-server.xml password=$PRIVATE_KEY_PASSWORD
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
  if [ ! -z "$DELAY" ] && [[ $DELAY =~ ^[0-9]+$ ]]; then
    sleep $DELAY
  fi
fi

exec "/opt/wso2am/bin/wso2server.sh"
