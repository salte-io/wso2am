FROM java:7-jdk

###############################################################################
# Steps
# 1) Downloads version 2.0.0 of the WSO2 API Manager platform.
# 2) Downloads version 5.1.38 of the MySql database driver.
# 3) Installs the zip command line tool.
# 4) Installs the Saxon XSL command line tool.
# 5) Installs the OpenSSL command line tool.
# 6) Unzips both the API Manager platform and the MySql database driver.
# 7) Copies the MySql database driver to the WSO2 lib folder.
# 8) Removes compressed files.
# 9) Creates a link to tie WSO2 log output to the Docker log file.
###############################################################################
RUN wget -P /opt http://192.168.1.50:8091/repository/wso2/api/2.0.0/platform.zip && \
    wget -P /tmp http://dev.mysql.com/Downloads/Connector-J/mysql-connector-java-5.1.38.zip && \
    apt-get update && \
    apt-get install -y zip && \
    apt-get install -y libsaxonb-java && \
    apt-get install -y openssl && \
    apt-get clean && \
    unzip /opt/platform.zip -d /opt && \
    mv /opt/wso2am-2.0.0 /opt/wso2am && \
    rm /opt/platform.zip && \
    unzip /tmp/mysql-connector-java-5.1.38.zip -d /tmp && \
    cp /tmp/mysql-connector-java-5.1.38/*.jar /opt/wso2am/repository/components/lib/. && \
    rm -r /tmp/mysql* && \
    ln -sf /dev/stdout /opt/wso2am/repository/logs/wso2carbon.log

###############################################################################
# Copies the transformation files used to map the WSO2 API Manager
# configuration files, based upon user-specified parameters, when the container
# is run for the first time.
###############################################################################
COPY *.xsl /tmp/

###############################################################################
# Custom entrypoint responsible for performing one-time setup when the
# container is run for the first time.
###############################################################################
COPY wso2am-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#------------------------------------------------------------------------------
# Ports exposed by console, publisher, store, runtime token, and runtime gateway.
# *** These may be used consistently because...
#     they can be kept internal to the container and...
#     we will NEVER host multiple WSO2 products within a single container. ***
#------------------------------------------------------------------------------
#EXPOSE 9443 9763 8243 8280

ENTRYPOINT ["/entrypoint.sh"]
