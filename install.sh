#!/bin/bash

# Install CrowdSec
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
sudo apt install crowdsec -y

# Check the status of CrowdSec
sudo systemctl status crowdsec

# Install the iptables firewall bouncer
sudo apt install crowdsec-firewall-bouncer-iptables -y

# Create a configuration file for the whitelist
echo "name: crowdsecurity/whitelists
description: \"Whitelist events from my IP addresses\"
whitelist:
  reason: \"my IP addresses / ranges\"
  ip:
    - \"127.0.0.1\"
    - \"::1\"
    - \"177.68.194.93\"
    - \"189.79.179.117\"
    - \"10.35.12.4\"
  cidr:
    - \"192.168.0.0/16\"
    - \"172.16.0.0/12\"
    - \"10.0.0.0/8\"" | sudo tee /etc/crowdsec/parsers/s02-enrich/mywhitelists.yaml

# Reload CrowdSec configuration
sudo systemctl reload crowdsec

# Install the specified plugins using cscli
sudo cscli collections install crowdsecurity/http-cve
sudo cscli collections install lourys/pterodactyl
sudo cscli collections install crowdsecurity/iptables
sudo systemctl reload crowdsec

# Dashboard token
sudo systemctl restart crowdsec

# Prompt the user to input their CrowdSec console enrollment key
echo "Please enter your CrowdSec console enrollment key:"
read -r ENROLLMENT_KEY

# Use the entered key in the cscli command
sudo cscli console enroll "$ENROLLMENT_KEY"

# Restart CrowdSec
sudo systemctl restart crowdsec

echo "CrowdSec is installed, the whitelist is configured, and the specified plugins are installed."
