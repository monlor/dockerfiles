FROM lovechen/embyserver:latest

ARG TARGETARCH

ENV RCLONE_VERSION=v1.65.2

RUN wget https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip && \
    unzip rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip && \
    cp -rf rclone-${RCLONE_VERSION}-linux-${TARGETARCH}/rclone /usr/bin/ && \
    rm -rf rclone-${RCLONE_VERSION}-linux-${TARGETARCH} rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip