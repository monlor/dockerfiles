# Nginx Proxy Manager with Authelia

## Quick Start

```bash
docker run -d \
  --name monlor/nginx-proxy-manager \
  -p 80:80 \
  -p 443:443 \
  -e AUTHELIA_URL=http://authelia:9091 \
  -v /path/to/data:/data \
  -v /path/to/certbot:/etc/letsencrypt \
  monlor/nginx-proxy-manager:latest
```

## Environment Variables

- `AUTHELIA_URL`: The URL of the Authelia server.

## References

- [Nginx Proxy Manager with Authelia](https://www.authelia.com/integration/proxies/nginx-proxy-manager/#protected-application-custom-locations)