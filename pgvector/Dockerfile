FROM pgvector/pgvector:pg17 AS builder

FROM bitnami/postgresql:17.2.0-debian-12-r10

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

COPY --from=builder /usr/lib/postgresql/17/lib/vector.so /opt/bitnami/postgresql/lib/
COPY --from=builder /usr/share/postgresql/17/extension/vector* /opt/bitnami/postgresql/share/extension/