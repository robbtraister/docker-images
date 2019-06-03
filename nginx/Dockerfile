FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
            nginx \
            && \
    rm -rf /var/cache/apk/* && \
    nginx -v

ARG USER=nginx
ENV USER=${USER}

RUN \
    (addgroup -S ${USER} 2> /dev/null || true) && \
    (adduser -S ${USER} -G ${USER} -s /bin/sh 2> /dev/null || true)

ARG PROJECT=nginx
WORKDIR /opt/${PROJECT}

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
