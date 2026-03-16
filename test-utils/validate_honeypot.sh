#!/bin/bash
# validate_honeypot.sh - Post-deployment validation script for Linux

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting Honeypot Deployment Validation..."

# 1. Check if honeypot files exist
echo -n "[ ] Checking honeypot files... "
if [ -f "$HOME/.bitcoin/wallet.dat" ] || [ -d "$HOME/.ethereum/keystore" ]; then
    echo -e "${GREEN}DONE${NC}"
else
    echo -e "${RED}FAILED${NC} (No artifacts found in $HOME)"
fi

# 2. Check Wazuh Agent status
echo -n "[ ] Checking Wazuh Agent... "
if systemctl is-active --quiet wazuh-agent; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}NOT RUNNING${NC}"
fi

# 3. Check auditd status
echo -n "[ ] Checking auditd... "
if systemctl is-active --quiet auditd; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}NOT RUNNING${NC} (Required for whodata FIM)"
fi

# 4. Check Audit Rules
echo -n "[ ] Checking Honeypot Audit Rules... "
if auditctl -l | grep -q "crypto_honeypot"; then
    echo -e "${GREEN}LOADED${NC}"
else
    echo -e "${RED}NOT FOUND${NC} (Run: sudo auditctl -R /etc/audit/rules.d/honeypot.rules)"
fi

# 5. Simulate access (OPTIONAL)
read -p "Do you want to trigger a test alert? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Accessing $HOME/.bitcoin/wallet.dat..."
    cat "$HOME/.bitcoin/wallet.dat" > /dev/null 2>&1
    echo -e "${GREEN}Test access performed.${NC} Check your Wazuh dashboard for Rule 100501."
fi

echo "Validation Complete."
