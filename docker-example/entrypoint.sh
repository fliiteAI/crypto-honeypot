#!/bin/bash
set -e

OSSEC_CONF="/var/ossec/etc/ossec.conf"

# Configure Wazuh Manager IP if provided
if [ -n "$WAZUH_MANAGER" ]; then
    echo "Setting Wazuh Manager IP to $WAZUH_MANAGER"
    # More robust substitution that handles multiple address formats
    sed -i "s|<address>.*</address>|<address>$WAZUH_MANAGER</address>|g" "$OSSEC_CONF"
fi

# Configure Agent Name if provided
if [ -n "$NODE_NAME" ]; then
    echo "Setting Node Name to $NODE_NAME"
    echo "node_name=$NODE_NAME" >> /var/ossec/etc/local_internal_options.conf
fi

# Deploy honeypot artifacts
echo "Deploying honeypot artifacts..."
honeypot-deployer generate --output /opt/honeypot/artifacts --no-encrypt-manifest

# Configure FIM for the generated artifacts
echo "Generating Wazuh FIM configuration..."
honeypot-deployer wazuh-config --manifest /opt/honeypot/artifacts/manifest.json --os linux --output /tmp/wazuh-config

# Insert FIM config into ossec.conf within the <syscheck> section
# We use a temporary file to build the new config
FIM_SNIPPET="/tmp/wazuh-config/honeypot-fim.conf"
if [ -f "$FIM_SNIPPET" ]; then
    echo "Injecting FIM configuration into $OSSEC_CONF"
    # Find the line number of </syscheck> and insert the snippet before it
    LINE_NUM=$(grep -n "</syscheck>" "$OSSEC_CONF" | head -n 1 | cut -d: -f1)
    if [ -n "$LINE_NUM" ]; then
        # Use sed to insert the file content before the closing syscheck tag
        sed -i "${LINE_NUM}i <!-- Honeypot FIM Config Start -->" "$OSSEC_CONF"
        sed -i "${LINE_NUM}r $FIM_SNIPPET" "$OSSEC_CONF"
    else
        echo "Error: Could not find </syscheck> in $OSSEC_CONF"
        exit 1
    fi
fi

# Start Wazuh Agent
echo "Starting Wazuh Agent..."
/var/ossec/bin/wazuh-control start

# Keep container running and tail logs
tail -f /var/ossec/logs/ossec.log
