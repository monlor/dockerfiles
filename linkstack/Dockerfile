FROM linkstackorg/linkstack

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV LINKSTACK_VERSION=v4.8.0

RUN apk add --no-cache rsync

RUN curl -Lo /tmp/linkstack.zip https://github.com/LinkStackOrg/LinkStack/releases/download/${LINKSTACK_VERSION}/linkstack.zip && \
    unzip /tmp/linkstack.zip -d /tmp && \
    rm -rf /htdocs && \
    rsync -avz --delete /tmp/linkstack /htdocs && \
    chown -R apache:apache /htdocs && \
    rm -rf /tmp/*

ADD https://raw.githubusercontent.com/LinkStackOrg/LinkStack/${LINKSTACK_VERSION}/storage/templates/advanced-config.php /tmp

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD []