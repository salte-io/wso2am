#!/bin/bash
set -eo pipefail

if [ ! -f "/opt/wso2am/repository/conf/initialized" ]; then
  cd /opt/wso2am/repository/resources/security
  openssl pkcs12 -export -in $PUBLIC_CERTIFICATE -inkey $PRIVATE_KEY -out wso2carbon.p12 -name wso2carbon -passout pass:$PRIVATE_KEY_PASSWORD
  keytool -delete -alias wso2carbon -keystore wso2carbon.jks -storepass wso2carbon
  keytool -importkeystore -noprompt -deststorepass wso2carbon -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore wso2carbon.jks -srckeystore wso2carbon.p12 -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD -alias wso2carbon
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore wso2carbon.jks -storepass wso2carbon
  keytool -delete -alias wso2carbon -keystore client-truststore.jks -storepass wso2carbon
  keytool -importcert -noprompt -alias wso2carbon -keystore client-truststore.jks -storepass wso2carbon -file $PUBLIC_CERTIFICATE
  keytool -storepasswd -new $PRIVATE_KEY_PASSWORD -keystore client-truststore.jks -storepass wso2carbon
  rm wso2carbon.p12
  saxonb-xslt -s:/opt/wso2am/repository/conf/axis2/axis2.xml -xsl:/tmp/axis2.xsl -o:/opt/wso2am/repository/conf/axis2/axis2.xml password=$PRIVATE_KEY_PASSWORD keystore=/opt/wso2am/repository/resources/security/wso2carbon.jks
  saxonb-xslt -s:/opt/wso2am/repository/conf/carbon.xml -xsl:/tmp/carbon.xsl -o:/opt/wso2am/repository/conf/carbon.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD keystore=/opt/wso2am/repository/resources/security/wso2carbon.jks alias=wso2carbon offset=$OFFSET
  saxonb-xslt -s:/opt/wso2am/repository/conf/api-manager.xml -xsl:/tmp/api-manager.xsl -o:/opt/wso2am/repository/conf/api-manager.xml hostname=$EXTERNAL_HOSTNAME password=$PRIVATE_KEY_PASSWORD thriftserver=localhost
  saxonb-xslt -s:/opt/wso2am/repository/conf/identity.xml -xsl:/tmp/identity.xsl -o:/opt/wso2am/repository/conf/identity.xml hostname=$EXTERNAL_HOSTNAME offset=$OFFSET
  saxonb-xslt -s:/opt/wso2am/repository/conf/user-mgt.xml -xsl:/tmp/user-mgt.xsl -o:/opt/wso2am/repository/conf/user-mgt.xml userds=jdbc/WSO2UM_DB password=$ADMIN_PASSWORD
  saxonb-xslt -s:/opt/wso2am/repository/conf/registry.xml -xsl:/tmp/registry.xsl -o:/opt/wso2am/repository/conf/registry.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT regds=jdbc/WSO2REG_DB regdb=regdb dbuser=$DATABASE_USER
  saxonb-xslt -s:/opt/wso2am/repository/conf/datasources/master-datasources.xml -xsl:/tmp/master-datasources.xsl -o:/opt/wso2am/repository/conf/datasources/master-datasources.xml sqlhost=$DATABASE_HOSTNAME sqlport=$DATABASE_PORT apidb=apimgtdb userdb=userdb userds=jdbc/WSO2UM_DB regdb=regdb regds=jdbc/WSO2REG_DB dbuser=$DATABASE_USER dbpassword=$DATABASE_PASSWORD
  rm /tmp/*.xsl
  touch /opt/wso2am/repository/conf/initialized
  if echo $DELAY | egrep -q '^[0-9]+$'; then
    sleep $DELAY
  fi
fi

exec "/opt/wso2am/bin/wso2server.sh"
