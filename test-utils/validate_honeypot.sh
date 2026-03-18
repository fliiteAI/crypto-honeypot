#!/bin/bash
# validate_honeypot.sh - Verify Crypto Wallet Honeypot Deployment

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting Crypto Wallet Honeypot Validation..."

# 1. Check if honeypot-deployer is installed
if ! command -v honeypot-deployer &> /dev/null; then
    echo -e "${RED}[FAIL]${NC} honeypot-deployer CLI not found. Install with 'pip install .'"
    exit 1
else
    echo -e "${GREEN}[OK]${NC} honeypot-deployer CLI is installed."
fi

# 2. Check for artifacts and manifest
if [ -d "./honeypot-artifacts" ] && [ -f "./honeypot-artifacts/manifest.json" ]; then
    echo -e "${GREEN}[OK]${NC} Honeypot artifacts and manifest found."
else
    echo -e "${RED}[FAIL]${NC} Honeypot artifacts not found. Generate them with 'honeypot-deployer generate --output ./honeypot-artifacts'"
    exit 1
fi

# 3. Check Wazuh Agent configuration (Linux)
if [ -f "/var/ossec/etc/ossec.conf" ]; then
    if grep -q "bitcoin" /var/ossec/etc/ossec.conf; then
        echo -e "${GREEN}[OK]${NC} Wazuh FIM configuration appears to be present in ossec.conf"
    else
        echo -e "${RED}[FAIL]${NC} Wazuh FIM configuration missing or incomplete in /var/ossec/etc/ossec.conf"
    fi
else
    echo -e "[INFO] Skipping /var/ossec/etc/ossec.conf check (not a standard Linux Wazuh Agent installation path)"
fi

# 4. Check for auditd
if command -v auditctl &> /dev/null; then
    echo -e "${GREEN}[OK]${NC} auditd is installed."
else
    echo -e "${RED}[FAIL]${NC} auditd is not installed. High-fidelity whodata monitoring will not work."
fi

# 5. Run honeypot-deployer health-check
echo "Running honeypot-deployer health-check..."
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json

echo "Validation complete."
