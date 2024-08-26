#!/bin/bash

set -eu

# Configuration file for dnsmasq
CONFIG_FILE=/etc/dnsmasq.conf

# Define a list of SNI_IPs, separated by commas
IFS=',' read -r -a IP_LIST <<< "$SNI_IPS"  # Split the string into an array

# Set the interval for testing (in seconds)
# Default to 60 seconds if not set
INTERVAL=${TEST_INTERVAL:-60}

# Variable to hold the current IP
current_ip=""

# Function to test the current IP address
test_current_ip() {
  if [ -n "$current_ip" ] && curl -s --connect-timeout 5 "http://$current_ip:80" > /dev/null; then
    return 0
  else
    echo "$current_ip is not reachable."
    return 1
  fi
}

# Function to switch to the next available IP
switch_ip() {
  for ip in "${IP_LIST[@]}"; do
    if curl -s --connect-timeout 5 "http://$ip:80" > /dev/null; then
      echo "Switching to $ip."
      current_ip="$ip"
      return 0
    fi
  done
  echo "No available IP found."
  return 1
}

# Function to generate dnsmasq configuration for all domains using a specified IP
generate_dnsmasq_config() {
  local ip="$1"
  local config_file="$2"
  
  # Clear the existing configuration file
  : > "$config_file"

  # Write common dnsmasq settings
  cat >> "$config_file" <<EOF
domain-needed
bogus-priv
no-resolv
no-poll
all-servers
server=8.8.8.8
server=1.1.1.1
cache-size=2048
local-ttl=60
interface=*
EOF

  # Download domain list or use local file
  if [ -n "${MEDIA_DOMAIN_URL:=}" ]; then
    echo "Downloading domain list from ${MEDIA_DOMAIN_URL}"
    while read -r domain; do
      echo "address=/$domain/$ip" >> "$config_file"
    done <<< "$(curl -L "${MEDIA_DOMAIN_URL}" | grep -v '^#' | grep -v '^$')"
  else
    echo "Using domain list from /tmp/media.txt"
    while read -r domain; do
      echo "address=/$domain/$ip" >> "$config_file"
    done < /tmp/media.txt
  fi
}

# Initialize with the first available IP
switch_ip || exit 1

# Generate the initial dnsmasq configuration
generate_dnsmasq_config "$current_ip" "$CONFIG_FILE"

# Start dnsmasq in the background
dnsmasq -d &

# Periodically test the current IP and switch if necessary
while true; do
  if ! test_current_ip; then
    switch_ip || exit 1  # Switch to a new IP if the current one is not reachable

    # Update the dnsmasq configuration with the new reachable IP
    generate_dnsmasq_config "$current_ip" "$CONFIG_FILE"
  fi

  # Sleep for the specified interval before the next test
  sleep "$INTERVAL"
done