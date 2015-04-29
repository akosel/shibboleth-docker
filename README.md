
# Overview

This docker image contains a working Shibboleth + nginx FastCGI configuration.

## Versions

* Base OS: Debian Wheezy
* [Shibboleth](https://shibboleth.net/): 2.5.3
* [nginx](http://nginx.org/): 1.7.2
* [envplate](https://github.com/kreuzwerker/envplate): 0.0.7 

# How to use

## Prerequisites

* Docker 1.5

## Build the image

`docker build -t matter/shibboleth-nginx .`

## Run the container with environment variables

You will need to have port 80 available.

This runs the container in the foreground, which can be useful for debugging

````
docker run --rm -p 80:80 \
    -v $(pwd)/log:/var/log \
    -e CLIENT_APP_SCHEME=https \
    -e CLIENT_APP_HOSTNAME=your-app.localdomain.com \
    -e NGINX_PROXY_DESTINATION=http://172.17.42.1:8001 \
    matter/shibboleth-nginx
````

## SAML Id Providers

The default shibboleth config file has metadata entries for:

* [OpenIdP](https://openidp.feide.no/)
* [Testshib](https://www.testshib.org/)

## Environment vars and defaults

### CLIENT_APP_SCHEME

* The URL scheme used for fetching metadata
* Default: `https`


### CLIENT_APP_HOSTNAME

* The primary client application hostname. Should be fully-qualified and available outside your local network.
* Default: `your-app.localdomain.com`


### CLIENT_APP_SECURE_PATH

* The URL path used by Shibboleth as a 'secure' path. When this URL path is loaded, Shibboleth will
  intercept the request, force a login, and pass special headers across the nginx proxy.
* Default: `/app`


### SHIBBOLETH_RESPONDER_PATH

* The Shibboleth responder path. URLs using this path will be served by Shibboleth's `shibresponder`
* Default: `/saml`


### NGINX_PROXY_DESTINATION

* A URL where the web application is running. Defaults to port 8001 of the Docker host.
* Default: `http://172.17.42.1:8001`

## Expected paths

- Shibboleth base path: `/saml` (uses `SHIBBOLETH_RESPONDER_PATH`)
- Shibboleth Status reporting service: `/saml/status`
- Shibboleth Session diagnostic service: `/saml/session`
- SAML Metadata: `/saml/metadata`
- SAML ACS URL: `/saml/acs`
- SAML Login: `/saml/Login` (case-sensitive)

# Login URLs

* Default login (OpenIdP):
    * https://your-app.localdomain.com/saml/Login?target=/app
* Login with the Testshib IdP:
    * https://your-app.localdomain.com/saml/Login?target=/app&entityID=https://idp.testshib.org/idp/shibboleth

## Notes

### Build container

````
docker build -t matter/shibboleth-nginx .
````

### Run our container

#### Normal

With log directory mounted and some example environment variables

````
docker run -p 80:80 \
    -v $(pwd)/log:/var/log \
    -e CLIENT_APP_HOSTNAME=your-app.localdomain.com \
    -e NGINX_PROXY_DESTINATION=http://172.17.42.1:8001 \
    matter/shibboleth-nginx
````

### Run bash in our container

Also mount lots of directories. This allows you to override the default configuration files and templates.

````
docker run -p 80:80 -it \
    -v $(pwd)/shibboleth:/etc/shibboleth \
    -v $(pwd)/supervisor:/etc/supervisor/conf.d \
    -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d \
    -v $(pwd)/log:/var/log \
    matter/shibboleth-nginx /bin/bash
````

### Run supervisor in an 'envplate' context

Run this while in bash inside the container

````
/usr/local/bin/ep -v /etc/nginx/conf.d/default.conf /etc/shibboleth/shibboleth2.xml -- \
    /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
````

### Run supervisor

Run this while in bash inside the container

````
supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
````
