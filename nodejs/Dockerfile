FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
            nodejs-npm \
            && \
    rm -rf /var/cache/apk/* && \
    npm i -g npm && \
    node -v && \
    npm -v

ARG USER=nodejs
ENV USER=${USER}

RUN \
    (addgroup -S ${USER} 2> /dev/null || true) && \
    (adduser -S ${USER} -G ${USER} -s /bin/sh 2> /dev/null || true)

ARG PROJECT=nodejs
WORKDIR /opt/${PROJECT}

ENTRYPOINT ["node"]

ONBUILD ENTRYPOINT ["npm", "run"]
ONBUILD CMD ["start"]

ONBUILD COPY package*.json ./
ONBUILD RUN \
            npm install && \
            npm cache clean
ONBUILD COPY . ./

ONBUILD RUN \
            chown -R ${USER}:${USER} ./ && \
            chmod u=rwX,go= -R ./

ONBUILD USER ${USER}
