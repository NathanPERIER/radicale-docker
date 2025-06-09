FROM alpine:latest

RUN --mount=type=bind,source=./requirements.txt,target=/tmp/requirements.txt \
    apk update \
    && apk add --update --no-cache python3 py3-pip \
    && ln -sf python3 /usr/bin/python \
    && pip3 install --break-system-packages -r /tmp/requirements.txt

RUN mkdir /opt/radicale /etc/radicale
WORKDIR /opt/radicale
COPY start.sh ./

ENTRYPOINT ["sh", "start.sh"]

