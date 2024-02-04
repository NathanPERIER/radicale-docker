FROM alpine:latest

RUN apk update && apk add --update --no-cache python3 py3-pip && ln -sf python3 /usr/bin/python
RUN rm /usr/lib/python3.*/EXTERNALLY-MANAGED && pip3 install --upgrade radicale

RUN mkdir /opt/radicale /etc/radicale
WORKDIR /opt/radicale
COPY start.sh ./

ENTRYPOINT sh start.sh

