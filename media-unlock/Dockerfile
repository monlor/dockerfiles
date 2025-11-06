FROM ubuntu:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.1.0

RUN apt update && apt install -y dnsmasq bash curl python3 && apt clean

WORKDIR /app
COPY . /app

ENTRYPOINT ["python3", "/app/entrypoint.py"]
