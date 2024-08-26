#!/bin/bash

set -eu

# Configuration file for dnsmasq
CONFIG_FILE=/etc/dnsmasq.conf

# Define a list of SNI_IPs, separated by commas
IFS=',' read -r -a MEDIA_IP_LIST <<< "${MEDIA_IPS}"  # Split the string into an array
IFS=',' read -r -a OPENAI_IP_LIST <<< "${OPENAI_IPS:-}"  # Split the string into an array

# Set the interval for testing (in seconds)
# Default to 60 seconds if not set
INTERVAL=${TEST_INTERVAL:-60}

# Variable to hold the current IP
current_media_ip=""
current_openai_ip=""

# Function to test the current IP address
test_current_ip() {
  local current_ip="${1}"
  if [ -n "$current_ip" ] && curl -s --connect-timeout 5 "http://$current_ip:80" > /dev/null; then
    return 0
  else
    echo "$current_ip is not reachable."
    return 1
  fi
}

# Function to switch to the next available IP
switch_media_ip() {
  for ip in "${MEDIA_IP_LIST[@]}"; do
    if curl -s --connect-timeout 5 "http://$ip:80" > /dev/null; then
      echo "media: Switching to $ip."
      current_media_ip="$ip"
      return 0
    fi
  done
  echo "media: No available IP found."
  return 1
}

# Function to switch to the next available IP
switch_openai_ip() {
  for ip in "${OPENAI_IP_LIST[@]}"; do
    if curl -s --connect-timeout 5 "http://$ip:80" > /dev/null; then
      echo "openai: Switching to $ip."
      current_openai_ip="$ip"
      return 0
    fi
  done
  echo "openai: No available IP found."
}

# Function to generate dnsmasq configuration for all domains using a specified IP
generate_dnsmasq_config() {
  # Clear the existing configuration file
  : > "/tmp/dnsmasq.conf"

  # Write common dnsmasq settings
  cat >> "/tmp/dnsmasq.conf" <<EOF
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

  while read -r domain; do
    echo "address=/$domain/$current_media_ip" >> "/tmp/dnsmasq.conf"
  done < /tmp/media.txt

  if [ -n "${current_openai_ip}" ]; then
    while read -r domain; do
      echo "address=/$domain/$current_openai_ip" >> "/tmp/dnsmasq.conf"
    done < /tmp/openai.txt
  fi

  # Move the generated configuration to the actual dnsmasq configuration file
  mv -f "/tmp/dnsmasq.conf" "$CONFIG_FILE"
}

# Initialize with the first available IP
switch_media_ip || exit 1
switch_openai_ip

# Generate the initial dnsmasq configuration
generate_dnsmasq_config

# Start dnsmasq in the background
dnsmasq -d &

# Periodically test the current IP and switch if necessary
while true; do
  if ! test_current_ip "${current_media_ip}"; then
    switch_media_ip || exit 1  # Switch to a new IP if the current one is not reachable

    # Update the dnsmasq configuration with the new reachable IP
    generate_dnsmasq_config 
  fi

  if [ -n "${current_openai_ip}" ] && ! test_current_ip "${current_openai_ip}"; then
    switch_openai_ip

    # Update the dnsmasq configuration with the new reachable IP
    generate_dnsmasq_config 
  fi

  # Sleep for the specified interval before the next test
  sleep "$INTERVAL"
done