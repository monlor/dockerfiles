FROM golang:1.14.0 AS builder

WORKDIR /go/src

COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o http-dump .

FROM marcosmorelli/debian-base-image

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

WORKDIR /root/

COPY --from=0 /go/src/http-dump .

EXPOSE 8080

CMD ["./http-dump"]