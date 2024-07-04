FROM ghcr.io/cedar2025/xboard

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.1.0

COPY --chmod=0655 entrypoint.sh /entrypoint.sh

COPY EPay.php /www/app/Payments/EPay.php

ENTRYPOINT ["/entrypoint.sh"]

CMD []