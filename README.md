# WSO2 API Manager
Defines a WSO2 API Manager platform docker image that enables the consumer to override the most commonly overridden aspects of the default platform configuration.

## How to Use
1. Run the corresponding database container available on [Docker Hub](https://hub.docker.com/r/salte/mysql-wso2am/).
2. Run the image counterpart of this manifest available on [Docker Hub](https://hub.docker.com/r/salte/wso2am/) via the following command:
```
$ docker run --name wso2am --restart=always --detach \
             --publish=9443:9443 \
             --publish=9763:9763 \
             --publish=8280:8280 \
             --publish=8243:8243 \
             --volume=<host volume>:<container volume> \
             -e EXTERNAL_HOSTNAME=<DNS Hostname> \
             -e DATABASE_HOSTNAME=<DNS Hostname> \
             -e DATABASE_PORT=<port number> \
             -e DATABASE_USER=<username> \
             -e DATABASE_PASSWORD=<password> \
             -e PUBLIC_CERTIFICATE=<path and filename> \
             -e PRIVATE_KEY=<path and filename> \
             -e PRIVATE_KEY_PASSWORD=<password> \
             -e ADMIN_PASSWORD=<password> \
             -e DELAY=0 \
             -e OFFSET=0 \
             -e SSL_PROXY_PORT=443 \
             -e PROXY_PORT=80 \
             -e JWT_EXPIRY=5 \
             -e CA_CERTIFICATE_BUNDLE=<path and filename> \
             wso2am:<tag>
```
In the example above, "host volume" is the location on disk where the "public certificate file" and the "private key file" can be found.  "container volume" is where the "host volume" will be mounted inside of the container; making the aforementioned "public certificate file" and "private key file" available to the container's initialization process.  The value provided for "public certificate file" and "private key file" should incorporate this path within their respective values.  These files will be used to secure https communications.
