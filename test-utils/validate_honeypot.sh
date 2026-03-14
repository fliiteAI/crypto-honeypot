#!/bin/bash
# Post-deployment validation script for Crypto Wallet Honeypot (Linux)
# Verifies that artifacts are present and Wazuh/auditd are monitoring them.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Honeypot Deployment Validation...${NC}"

# 1. Check if auditd is running
if systemctl is-active --quiet auditd; then
    echo -e "[${GREEN}OK${NC}] auditd is running"
else
    echo -e "[${RED}FAIL${NC}] auditd is NOT running"
fi

# 2. Check if Wazuh agent is running
if systemctl is-active --quiet wazuh-agent; then
    echo -e "[${GREEN}OK${NC}] wazuh-agent is running"
else
    echo -e "[${RED}FAIL${NC}] wazuh-agent is NOT running"
fi

# 3. Verify core honeypot files
PATHS=(
    "$HOME/.bitcoin/wallet.dat"
    "$HOME/.ethereum/keystore"
    "$HOME/.config/solana/id.json"
)

for path in "${PATHS[@]}"; do
    # Expand tilde
    expanded_path="${path/#\~/$HOME}"
    if [ -e "$expanded_path" ]; then
        echo -e "[${GREEN}OK${NC}] Artifact exists: $path"
    else
        echo -e "[${YELLOW}INFO${NC}] Artifact missing (might not be deployed): $path"
    fi
done

# 4. Check audit rules
if command -v auditctl >/dev/null 2>&1; then
    if sudo auditctl -l | grep -q "crypto_honeypot"; then
        echo -e "[${GREEN}OK${NC}] Honeypot audit rules are loaded"
    else
        echo -e "[${RED}FAIL${NC}] Honeypot audit rules NOT found in auditctl"
    fi
else
    echo -e "[${RED}FAIL${NC}] auditctl command not found"
fi

# 5. Check Wazuh FIM config (basic check)
if [ -f "/var/ossec/etc/ossec.conf" ]; then
    if sudo grep -q "check_all=\"yes\"" /var/ossec/etc/ossec.conf; then
         echo -e "[${GREEN}OK${NC}] Wazuh FIM appears to be configured"
    else
         echo -e "[${YELLOW}WARN${NC}] Could not confirm FIM config in ossec.conf"
    fi
fi

echo -e "\n${YELLOW}Validation Complete.${NC}"
echo "To trigger a test alert, run: cat ~/.bitcoin/wallet.dat"
