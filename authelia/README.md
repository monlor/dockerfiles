## Run the Docker Container

Run the container with the necessary environment variables:

```bash
docker run -d \
  --name authelia \
  --network authelia-network \
  -e DOMAIN='your-domain.com' \
  -e AUTH_URL='https://auth.your-domain.com' \
  -e JWT_SECRET='your_jwt_secret' \
  -e SESSION_SECRET='your_session_secret' \
  -e STORAGE_ENCRYPTION_KEY='your_storage_encryption_key' \
  -e USER_PASSWORD='your_user_password' \
  -e USER_EMAIL='admin@your-domain.com' \
  -v /path/to/config:/config \
  monlor/authelia
```

## Environment Variables

Before running the script, ensure you have the following environment variables set:

- `DOMAIN`: The domain for which Authelia will be configured (e.g., `example.com`).
- `AUTH_URL`: The URL where Authelia is accessible (e.g., `https://auth.example.com`).
- `JWT_SECRET`: A secret key for JWT validation.
- `SESSION_SECRET`: A secret key for session encryption.
- `STORAGE_ENCRYPTION_KEY`: A key for encrypting storage data.
- `USER_PASSWORD`: The password for the admin user.
- `USER_EMAIL`: The email address for the admin user.
- `LOG_LEVEL`: (Optional) The logging level (default is `info`).

## Generate secret

```bash
openssl rand -base64 48
```