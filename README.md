# WSO2 API Manager
Defines a WSO2 API Manager platform docker image that enables the consumer to override the most commonly overridden aspects of the default platform configuration.

## How to Use
1. Run the cooresponding database container available on [Docker Hub](https://hub.docker.com/r/salte/mysql-wso2am/).
2. Run the image counterpart of this manifest available on [Docker Hub](https://hub.docker.com/r/salte/wso2am/) via the following command:
```
$ docker run --name=wso2am --restart=always --detach \
                --volume=<host volume>:<container volume> \
                --publish=9443:9443 \
                --publish=9763:9763 \
                --publish=8243:8243 \
                --publish=8280:8280 \
                -e EXTERNAL_HOSTNAME=<DNS Hostname> \
                -e DATABASE_HOSTNAME=<DNS Hostname> \
                -e DATABASE_PORT=<port number> \
                -e DATABASE_USER=<username> \
                -e DATABASE_PASSWORD=<password> \
                -e PUBLIC_CERTIFICATE=<public certificate file> \
                -e PRIVATE_KEY=<private key file> \
                -e PRIVATE_KEY_PASSWORD=<password> \
                -e ADMIN_PASSWORD=<password> wso2am:<tag>
```
In the example above, "host volume" is the location on disk where the consumer is placing both the "public certificate file" and the "private key file" that will be used to secure https communications.  In addition, "container volume" is where the "host volume" will be mounted inside of the container, thus making the aforementioned "public certificate file" and "private key file" available to the container's initialization process.  The value provided for "public certificate file" and "private key file" should incorporate this path within their respective values.
