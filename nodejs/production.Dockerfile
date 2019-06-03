FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
            nodejs \
            && \
    rm -rf /var/cache/apk/* && \
    node -v

ARG USER=nodejs
ENV USER=${USER}

RUN \
    (addgroup -S ${USER} 2> /dev/null || true) && \
    (adduser -S ${USER} -G ${USER} -s /bin/sh 2> /dev/null || true)

ARG PROJECT=nodejs
WORKDIR /opt/${PROJECT}

ENTRYPOINT ["node"]

ONBUILD CMD ["."]

ONBUILD COPY package*.json ./
ONBUILD RUN \
            apk add --no-cache --update \
                    npm \
                    && \
            npm install --production && \
            npm cache clean --force && \
            apk del npm && \
            rm -rf /var/cache/apk/*
ONBUILD COPY . ./

ONBUILD RUN \
            chown -R ${USER}:${USER} ./ && \
            chmod u=rwX,go= -R ./

ONBUILD USER ${USER}
