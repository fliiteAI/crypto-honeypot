#!/bin/bash
set -e

# Configuration
MANIFEST_PATH="/var/ossec/etc/honeypot-manifest.json"
ARTIFACT_DIR="/var/ossec/etc/honeypot-artifacts"
FIM_CONFIG_FILE="/var/ossec/etc/honeypot-fim.conf"

echo "Initializing Crypto Wallet Honeypot..."

# 1. Generate Honeypot Artifacts if they don't exist
if [ ! -f "$MANIFEST_PATH" ]; then
    echo "Generating new honeypot artifacts..."
    mkdir -p "$ARTIFACT_DIR"
    honeypot-deployer generate --output "$ARTIFACT_DIR" --no-encrypt-manifest
    mv "$ARTIFACT_DIR/manifest.json" "$MANIFEST_PATH"
else
    echo "Using existing manifest at $MANIFEST_PATH"
fi

# 2. Generate Wazuh Agent Configuration
echo "Generating Wazuh FIM configuration..."
honeypot-deployer wazuh-config --manifest "$MANIFEST_PATH" --os linux --output /tmp/wazuh-config-gen
cat /tmp/wazuh-config-gen/honeypot-fim.conf > "$FIM_CONFIG_FILE"

# 3. Inject FIM config into ossec.conf if not already present
if ! grep -q "honeypot-fim.conf" /var/ossec/etc/ossec.conf; then
    echo "Injecting FIM configuration into /var/ossec/etc/ossec.conf..."
    # Insert before the closing </syscheck> tag
    sed -i "/<\/syscheck>/e cat $FIM_CONFIG_FILE" /var/ossec/etc/ossec.conf
fi

# 4. Start the Wazuh agent
echo "Starting Wazuh agent..."
/var/ossec/bin/wazuh-control start
tail -f /var/ossec/logs/ossec.log
