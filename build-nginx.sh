#!/bin/bash

set -x

DEFAULT_VERSION="1.8.0"
dep_version=${VERSION:-$DEFAULT_VERSION}
dep_dirname=nginx-${dep_version}
dep_archive_name=${dep_dirname}.tar.gz
dep_url=http://nginx.org/download/${dep_archive_name}

pushd /tmp
    # Get nginx
    curl -L ${dep_url} | tar xz

    # Get the headers-more module
    curl -L https://github.com/openresty/headers-more-nginx-module/archive/v0.26.tar.gz | tar xz

    # Get the nginx shibboleth module
    git clone https://github.com/nginx-shib/nginx-http-shibboleth.git

    pushd $dep_dirname
        # Configure and build nginx
        ./configure \
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --user=_shibd \
            --group=_shibd \
            --with-debug \
            --with-http_ssl_module \
            --with-http_spdy_module \
            --with-http_realip_module \
            --with-pcre \
            --with-http_auth_request_module \
            --with-http_stub_status_module \
            --add-module=../headers-more-nginx-module-0.26 \
            --add-module=../nginx-http-shibboleth
        make && make install
    popd

    # Clean up a bit
    rm -Rf $dep_dirname ./headers-more-nginx-module-0.26 ./nginx-http-shibboleth
popd

