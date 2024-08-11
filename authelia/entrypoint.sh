#!/bin/sh

set -eu

# Create Authelia configuration file
cat <<EOF > /config/configuration.yml
server:
  address: tcp://0.0.0.0:9091

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: "*.${DOMAIN}"
      policy: two_factor

identity_validation:
  reset_password:
    jwt_secret: ${JWT_SECRET}

session:
  name: authelia_session
  secret: ${SESSION_SECRET}
  same_site: 'lax'
  inactivity: '5m'
  expiration: '1h'
  remember_me: '1M'
  cookies:
    - domain: '${DOMAIN}'
      authelia_url: '${AUTH_URL}'
      default_redirection_url: 'https://www.${DOMAIN}'
      name: 'authelia_session'
      same_site: 'lax'
      inactivity: '5m'
      expiration: '1h'
      remember_me: '1d'

totp:
  issuer: ${DOMAIN}
  period: 30
  skew: 1

storage:
  local:
    path: /config/db.sqlite3
  encryption_key: ${STORAGE_ENCRYPTION_KEY}

notifier:
  filesystem:
    filename: /config/notification.txt

log:
  level: ${LOG_LEVEL:-info}
EOF

# # Generate a TOTP secret for the user
# TOTP_SECRET=$(authelia storage user totp generate admin)

# # Print the TOTP secret to the console
# echo "Generated TOTP Secret for user 'alice': ${TOTP_SECRET}"

# Generate the hashed password using Authelia's built-in command
HASHED_PASSWORD=$(authelia crypto hash generate argon2 --password "${USER_PASSWORD}" | awk '{print$2}')

# Create users database file with hashed password and TOTP secret
cat <<EOF > /config/users_database.yml
users:
  admin:
    password: '${HASHED_PASSWORD}'
    displayname: Admin
    email: ${USER_EMAIL}
EOF

# Start Authelia
authelia --config /config/configuration.yml