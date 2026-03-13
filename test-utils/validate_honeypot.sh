#!/bin/bash
# Validation script for Crypto Wallet Honeypot (Linux)
# This script simulates an attacker's actions to verify detection.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Honeypot Validation...${NC}"

# 1. Check if artifacts exist
echo "Checking for honeypot artifacts..."
ARTIFACTS=(
    "$HOME/.bitcoin/wallet.dat"
    "$HOME/.ethereum/keystore"
    "$HOME/.config/solana/id.json"
)

EXIST_COUNT=0
for art in "${ARTIFACTS[@]}"; do
    if [ -e "$art" ] || [ -d "$art" ]; then
        echo -e "  [OK] Found $art"
        EXIST_COUNT=$((EXIST_COUNT+1))
    else
        echo -e "  [MISSING] $art"
    fi
done

if [ $EXIST_COUNT -eq 0 ]; then
    echo -e "${RED}Error: No artifacts found. Please run deploy.sh first.${NC}"
    # exit 1 # Don't exit here so we can see the failures in the sandbox
fi

# 2. Simulate Attack Actions
echo -e "\n${GREEN}Simulating attacker actions (this should trigger Wazuh alerts)...${NC}"

# Simulate discovery
echo "  Action: Listing honeypot directory..."
ls -R $HOME/.bitcoin 2>/dev/null || true

# Simulate read
echo "  Action: Reading Bitcoin wallet..."
if [ -f "$HOME/.bitcoin/wallet.dat" ]; then
    cat "$HOME/.bitcoin/wallet.dat" > /dev/null
    echo "  [OK] Read successful."
else
    echo "  [SKIP] Bitcoin wallet not found."
fi

# Simulate Ethereum keystore access
echo "  Action: Listing Ethereum keystore..."
if [ -d "$HOME/.ethereum/keystore" ]; then
    ls "$HOME/.ethereum/keystore" > /dev/null
    echo "  [OK] List successful."
else
    echo "  [SKIP] Ethereum keystore not found."
fi

echo -e "\n${GREEN}Validation actions completed.${NC}"
echo "Check your Wazuh dashboard for Rule IDs 100500, 100501, etc."
