FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
            curl \
            openssl \
            pcre \
            zlib \
            && \
    rm -rf /var/cache/apk/* && \
    openssl version

ARG USER=nginx
ENV USER=${USER}

RUN \
    (addgroup -S ${USER} 2> /dev/null || true) && \
    (adduser -S ${USER} -G ${USER} -s /bin/sh 2> /dev/null || true)

ARG PROJECT=nginx
WORKDIR /opt/${PROJECT}

ARG NGINX_VERSION=1.17.0

# build nginx with custom modules
RUN \
    # --- add dev packages
    DEV_PACKAGES='g++ git make openssl-dev pcre-dev wget zlib-dev' && \
    apk add --update --no-cache ${DEV_PACKAGES} && \
    # --- download nginx src
    wget --no-check-certificate -O nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx.tar.gz --strip-components 1 && \
    rm nginx.tar.gz && \
    # --- download ngx_devel_kit module
    # git clone --branch=master --single-branch --depth=1 https://github.com/simplresty/ngx_devel_kit ./modules/ngx_devel_kit && \
    # rm -rf ./modules/ngx_devel_kit/.git && \
    # --- download nginx let module
    # git clone --branch=master --single-branch --depth=1 https://github.com/arut/nginx-let-module ./modules/nginx-let && \
    # rm -rf ./modules/nginx-let/.git && \
    # --- download nginx set-misc module
    # git clone --branch=master --single-branch --depth=1 https://github.com/openresty/set-misc-nginx-module ./modules/nginx-set-misc && \
    # rm -rf ./modules/nginx-set-misc/.git && \
    # --- build nginx
    ./configure \
                --user=${USER} \
                --group=${USER} \
                --with-http_realip_module \
                # --add-module=modules/ngx_devel_kit \
                # --add-module=modules/nginx-let \
                # --add-module=modules/nginx-set-misc \
                && \
    make -j2 && \
    make install && \
    ln -sf `pwd`/objs/nginx /usr/bin/nginx && \
    rm -rf \
       ./CHANGES* \
       ./auto \
       ./modules \
       ./objs/src \
       ./src \
       && \
    nginx -v && \
    # --- remove dev packages
    apk del ${DEV_PACKAGES} && \
    rm -rf /var/cache/apk/* && \
    chown -R ${USER}:${USER} ./

RUN \
    mkdir -p \
             ./logs \
             ./tmp \
             && \
    ln -sf /dev/stdout ./logs/access.log && \
    ln -sf /dev/stdout ./logs/error.log

ENTRYPOINT ["nginx", "-g", "daemon off; pid ./nginx.pid;", "-p", "./", "-c"]
CMD ["./nginx.conf"]

ONBUILD COPY . ./

ONBUILD RUN \
            chown -R ${USER}:${USER} ./ && \
            chmod u=rwX,go= -R ./

ONBUILD USER ${USER}
