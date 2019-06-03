FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
            py2-pip \
            && \
    python -V && \
    pip -V

ARG USER=python
ENV USER=${USER}

RUN \
    (addgroup -S ${USER} 2> /dev/null || true) && \
    (adduser -S ${USER} -G ${USER} -s /bin/sh 2> /dev/null || true)

ARG PROJECT=python
WORKDIR /opt/${PROJECT}

ENTRYPOINT ["python"]

ONBUILD CMD ["./run.py"]

ONBUILD COPY requirements.txt ./
ONBUILD RUN \
            pip install -r ./requirements.txt
ONBUILD COPY . ./

ONBUILD RUN \
            chown -R ${USER}:${USER} ./ && \
            chmod u=rwX,go= -R ./

ONBUILD USER ${USER}
