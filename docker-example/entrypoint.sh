#!/bin/bash
set -e

# 1. Generate Honeypot Artifacts if they don't exist
if [ ! -d "/var/lib/honeypot/artifacts" ]; then
    echo "Generating honeypot artifacts..."
    mkdir -p /var/lib/honeypot
    honeypot-deployer generate --output /var/lib/honeypot/artifacts
fi

# 2. Inject FIM configuration into ossec.conf
OSSEC_CONF="/var/ossec/etc/ossec.conf"
if ! grep -q "honeypot-deployer" "$OSSEC_CONF"; then
    echo "Injecting honeypot FIM configuration..."

    # Generate the config snippet
    honeypot-deployer wazuh-config \
        --manifest /var/lib/honeypot/artifacts/manifest.json \
        --os linux \
        --output /tmp/honeypot-fim.conf

    # Read the snippet and insert it before the closing </syscheck> tag
    # Using a temporary file to handle potential special characters in the snippet
    sed -i '/<\/syscheck>/e cat /tmp/honeypot-fim.conf' "$OSSEC_CONF"
fi

# 3. Start the Wazuh Agent
echo "Starting Wazuh Agent..."
/init
