# frpc Docker Service

This is a Docker service for frpc (Fast Reverse Proxy Client) that uses environment variables for configuration. You can easily set up various network tunnels by configuring environment variables.

## Usage

1. Pull the Docker image:

```bash
docker pull monlor/frpc
```

2. Run the Docker container with the necessary environment variables:

```bash
docker run -d \
  -e SERVER_ADDR=your_frps_server_address \
  -e SERVER_PORT=7000 \
  -e TOKEN=your_frps_token \
  -e TCP_SSH_22=127.0.0.1:22 \
  -e HTTP_WEB_WWW=127.0.0.1:80 \
  monlor/frpc
```

## Environment Variables

- `SERVER_ADDR`: frps server address (default: 127.0.0.1)
- `SERVER_PORT`: frps server port (default: 7000)
- `TOKEN`: frps authentication token (optional)

### Configuring Tunnels

You can configure tunnels by adding environment variables. The format is as follows:

1. TCP/UDP/KCP:
   ```
   {PROTOCOL}_{NAME}_{REMOTE_PORT}=LOCAL_IP:LOCAL_PORT
   ```

2. HTTP/HTTPS:
   ```
   {PROTOCOL}_{NAME}_{DOMAIN}=LOCAL_IP:LOCAL_PORT
   ```

3. HTTP_PROXY:
   ```
   PROXY_{NAME}_{REMOTE_PORT}_{USER}={PASSWORD}
   ```

- `PROTOCOL`: Can be TCP, UDP, HTTP, HTTPS, or KCP
- `NAME`: Configuration name
- `REMOTE_PORT`: Port on the remote server
- `LOCAL_IP`: Local IP address
- `LOCAL_PORT`: Local port
- `DOMAIN`: Domain or subdomain for HTTP/HTTPS services (use underscores instead of dots for full domains)
- `USER`: Username for HTTP proxy
- `PASSWORD`: Password for HTTP proxy

Examples:

- `TCP_SSH_22=127.0.0.1:22`: Map local port 22 (SSH service) to remote server port 22
- `HTTP_WEB_WWW=127.0.0.1:80`: Map local port 80 (Web service) to subdomain www
- `HTTP_WEB_WWW_EXAMPLE_COM=127.0.0.1:80`: Map local port 80 to custom domain www.example.com
- `PROXY_HTTP_8080_USER=password`: Configure HTTP proxy on remote port 8080 with authentication

You can add any number of similar environment variables to configure multiple tunnels.

## Notes

- Ensure your frps server is properly configured and running
- Adjust firewall settings as needed to allow necessary port communications
- Do not expose sensitive services in public environments
- Some configuration types may require corresponding settings on the frps server side
- All domain names and configuration names are converted to lowercase in the final configuration
