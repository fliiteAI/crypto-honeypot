#!/bin/bash
set -e

# 1. Generate Honeypot Artifacts
echo "Generating honeypot artifacts..."
if [ -n "$MANIFEST_PASSWORD" ]; then
    honeypot-deployer generate --output /honeypot-artifacts --password "$MANIFEST_PASSWORD"
else
    honeypot-deployer generate --output /honeypot-artifacts --no-encrypt-manifest
fi

# 2. Generate Wazuh FIM Configuration
echo "Generating Wazuh FIM configuration..."
wazuh_config_cmd="honeypot-deployer wazuh-config --manifest /honeypot-artifacts/manifest.json --os linux --output /tmp/honeypot-fim.conf"
if [ -n "$MANIFEST_PASSWORD" ]; then
    $wazuh_config_cmd --password "$MANIFEST_PASSWORD"
else
    $wazuh_config_cmd
fi

# 3. Inject configuration into Wazuh Agent (if ossec.conf exists)
OSSEC_CONF="/var/ossec/etc/ossec.conf"
if [ -f "$OSSEC_CONF" ]; then
    echo "Injecting FIM configuration into $OSSEC_CONF..."
    # Using sed to insert the honeypot config before the end of the syscheck block
    # /r reads the file and appends it after the match
    sed -i '/<\/syscheck>/r /tmp/honeypot-fim.conf' "$OSSEC_CONF"
else
    echo "Wazuh ossec.conf not found at $OSSEC_CONF. Skipping injection."
    echo "Custom FIM configuration is available at /tmp/honeypot-fim.conf"
fi

echo "Honeypot deployment complete. Starting agent..."

# Execute the passed command (e.g., wazuh-agent)
exec "$@"
