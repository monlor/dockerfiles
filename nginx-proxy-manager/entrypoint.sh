#!/bin/sh

sed -i "s@set \$upstream_authelia .*@set \$upstream_authelia ${AUTHELIA_URL:-http://authelia:9091}/api/authz/auth-request;@g" /snippets/authelia-location.conf

exec /init