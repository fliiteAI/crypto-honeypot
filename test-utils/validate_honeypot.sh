#!/bin/bash
# post-deployment validation script for Linux

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "--- Honeypot Deployment Validation (Linux) ---"

# 1. Check if artifacts exist
echo -n "Checking for honeypot artifacts... "
if [ -f "$HOME/.bitcoin/wallets/wallet.dat" ] || [ -d "$HOME/.ethereum/keystore" ]; then
    echo -e "${GREEN}PRESENT${NC}"
else
    echo -e "${RED}MISSING${NC}"
fi

# 2. Check Wazuh Agent Status
echo -n "Checking Wazuh Agent status... "
if systemctl is-active --quiet wazuh-agent; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}STOPPED${NC}"
fi

# 3. Check Auditd
echo -n "Checking auditd status... "
if systemctl is-active --quiet auditd; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}STOPPED${NC}"
fi

# 4. Check FIM Configuration
echo -n "Checking FIM configuration for honeypot paths... "
if grep -qi "bitcoin" /var/ossec/etc/ossec.conf; then
    echo -e "${GREEN}CONFIGURED${NC}"
else
    echo -e "${RED}NOT FOUND${NC}"
fi

echo "--------------------------------------------"
echo "To trigger a test alert, run: cat ~/.bitcoin/wallets/wallet.dat"
