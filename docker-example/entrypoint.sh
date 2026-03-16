#!/bin/bash
# entrypoint.sh - Automated artifact generation and FIM injection for Docker

set -e

# 1. Generate Honeypot Artifacts
echo "Generating honeypot artifacts..."
honeypot-deployer generate --output /honeypot-artifacts --no-encrypt-manifest

# 2. Generate Wazuh FIM Snippet
echo "Generating Wazuh configuration..."
honeypot-deployer wazuh-config \
    --manifest /honeypot-artifacts/manifest.json \
    --os linux \
    --output /tmp/honeypot-fim.conf

# 3. Inject FIM config into ossec.conf
# This looks for the </syscheck> closing tag and inserts our config before it
if [ -f "/var/ossec/etc/ossec.conf" ]; then
    echo "Injecting FIM configuration into ossec.conf..."
    # Insert a marker before the closing tag
    sed -i '/<\/syscheck>/i \    <!-- Honeypot FIM Configuration BEGIN -->' /var/ossec/etc/ossec.conf
    # Read the generated snippet into the file after the marker
    sed -i '/<!-- Honeypot FIM Configuration BEGIN -->/r /tmp/honeypot-fim.conf' /var/ossec/etc/ossec.conf
fi

# 4. Start the original Wazuh Agent entrypoint
echo "Starting Wazuh Agent..."
exec /init
