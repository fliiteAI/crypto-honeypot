#!/bin/bash

# Crypto Honeypot Post-Deployment Validation Script (Linux)
# This script simulates attacker activity to verify Wazuh detection.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting Crypto Honeypot Validation..."

# 1. Test Bitcoin Wallet Access (Read/Modify)
echo -n "[*] Testing Bitcoin wallet access... "
if [ -f "$HOME/.bitcoin/wallet.dat" ]; then
    cat "$HOME/.bitcoin/wallet.dat" > /dev/null
    echo "TAMPER" >> "$HOME/.bitcoin/wallet.dat"
    echo -e "${GREEN}DONE${NC}"
else
    echo -e "${RED}SKIPPED (File not found)${NC}"
fi

# 2. Test Ethereum Keystore (Read)
echo -n "[*] Testing Ethereum keystore access... "
ETH_FILE=$(ls $HOME/.ethereum/keystore/UTC--* 2>/dev/null | head -n 1)
if [ -n "$ETH_FILE" ]; then
    cat "$ETH_FILE" > /dev/null
    echo -e "${GREEN}DONE${NC}"
else
    echo -e "${RED}SKIPPED (File not found)${NC}"
fi

# 3. Test Solana Config (Read)
echo -n "[*] Testing Solana config access... "
if [ -f "$HOME/.config/solana/id.json" ]; then
    grep "address" "$HOME/.config/solana/id.json" > /dev/null 2>&1
    echo -e "${GREEN}DONE${NC}"
else
    echo -e "${RED}SKIPPED (File not found)${NC}"
fi

# 4. Test Browser Extension Data (Read/Delete)
echo -n "[*] Testing Browser Extension data access... "
EXT_LOG=$(ls $HOME/.config/google-chrome/Default/Local\ Extension\ Settings/nkbihfbeogaeaoehlefnkodbefgpgknn/000003.log 2>/dev/null)
if [ -n "$EXT_LOG" ]; then
    cat "$EXT_LOG" > /dev/null
    rm "$EXT_LOG"
    echo -e "${GREEN}DONE${NC}"
else
    # Try Brave if Chrome fails
    EXT_LOG=$(ls $HOME/.config/BraveSoftware/Brave-Browser/Default/Local\ Extension\ Settings/nkbihfbeogaeaoehlefnkodbefgpgknn/000003.log 2>/dev/null)
    if [ -n "$EXT_LOG" ]; then
        cat "$EXT_LOG" > /dev/null
        rm "$EXT_LOG"
        echo -e "${GREEN}DONE${NC}"
    else
        echo -e "${RED}SKIPPED (File not found)${NC}"
    fi
fi

echo -e "\n${GREEN}Validation actions completed.${NC}"
echo "Check your Wazuh Dashboard for alerts (Level 12) related to 'Crypto Honeypot'."
