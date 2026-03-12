#!/bin/bash
# validate_honeypot.sh - Verify Linux honeypot deployment and Wazuh integration

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}--- Crypto Wallet Honeypot: Linux Validation ---${NC}"

# 1. Check if auditd is installed and running
echo -n "Checking auditd... "
if systemctl is-active --quiet auditd; then
    echo -e "${GREEN}Running${NC}"
else
    echo -e "${RED}NOT RUNNING${NC} (Required for high-fidelity detection)"
fi

# 2. Check for honeypot artifacts
echo -e "\nChecking for honeypot artifacts:"
ARTIFACTS=(
    "$HOME/.bitcoin/wallet.dat"
    "$HOME/.ethereum/keystore"
    "$HOME/.config/solana/id.json"
    "$HOME/.electrum/wallets/default_wallet"
    "$HOME/.config/Exodus/exodus.wallet/seed.secur"
)

for file in "${ARTIFACTS[@]}"; do
    if [ -e "$file" ]; then
        perms=$(stat -c "%a" "$file")
        echo -e "  [${GREEN}OK${NC}] $file (Perms: $perms)"
    else
        echo -e "  [${YELLOW}MISSING${NC}] $file"
    fi
done

# 3. Check for browser extension decoys
echo -e "\nChecking browser extension decoys:"
EXT_IDS=("nkbihfbeogaeaoehlefnkodbefgpgknn" "bfnaelmomeimhlpmgjnjophhpkkoljpa")
CHROME_PATH="$HOME/.config/google-chrome/Default/Local Extension Settings"

for id in "${EXT_IDS[@]}"; do
    if [ -d "$CHROME_PATH/$id" ]; then
        echo -e "  [${GREEN}OK${NC}] Chrome Decoy: $id"
    else
        echo -e "  [${YELLOW}MISSING${NC}] Chrome Decoy: $id"
    fi
done

# 4. Check for active audit rules
echo -e "\nChecking active audit rules:"
if command -v auditctl &> /dev/null; then
    rules=$(sudo auditctl -l | grep -c "honeypot")
    if [ "$rules" -gt 0 ]; then
        echo -e "  [${GREEN}OK${NC}] $rules active honeypot audit rules found."
    else
        echo -e "  [${RED}ERROR${NC}] No honeypot audit rules found in active configuration."
    fi
else
    echo -e "  [${YELLOW}SKIP${NC}] auditctl command not found."
fi

# 5. Check Wazuh Agent Status
echo -e "\nChecking Wazuh Agent:"
if [ -f "/var/ossec/bin/wazuh-control" ]; then
    status=$(/var/ossec/bin/wazuh-control status | grep "ossec-agentd is running")
    if [ -n "$status" ]; then
        echo -e "  [${GREEN}OK${NC}] Wazuh Agent is running."
    else
        echo -e "  [${RED}ERROR${NC}] Wazuh Agent is NOT running."
    fi
else
    echo -e "  [${YELLOW}SKIP${NC}] Wazuh agent not found in standard path."
fi

echo -e "\n${YELLOW}Validation Complete.${NC}"
