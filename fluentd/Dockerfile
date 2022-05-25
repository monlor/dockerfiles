FROM fluentd:v1.9.1-1.0

LABEL MAINTAINER="me@monlor.com"

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
  && sudo gem install fluent-plugin-kafka \
  && sudo gem sources --clear-all \
  && apk del .build-deps \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

USER fluent