FROM kubesphere/kubectl:v1.22.0

ARG TARGETARCH

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

RUN apk add openssl

ENV HELMFILE_VERSION "0.165.0"

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -#fSLO https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar -zxf helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/local/bin helmfile && \
    rm -rf helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz