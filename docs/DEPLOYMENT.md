# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Browser Extension Decoys](#browser-extension-decoys)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Hardware Recommendations
- **Wazuh Manager:** Raspberry Pi 4 (8GB) or Raspberry Pi 5. Use of a high-endurance microSD card or USB 3.0 SSD is strongly recommended.
- **Wazuh Agent:** Any supported Linux or Windows endpoint.

### Network Requirements
The following ports must be open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016+.

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
Copy the custom configurations to your Wazuh Manager:
```bash
# Decoders
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Active Response Setup
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 3. Restart Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup
1. **Install Auditd:** Required for `whodata` monitoring.
   ```bash
   sudo apt update && sudo apt install auditd -y
   ```
2. **Configure FIM:** Add honeypot paths to `/var/ossec/etc/ossec.conf`. Use `honeypot-deployer wazuh-config` to generate specific snippets.
3. **Audit Rules:**
   ```bash
   cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```

### Windows Setup
1. **Sysmon:** Install with the provided configuration template: `wazuh/agent-config/honeypot-sysmon.xml`.
2. **FIM:** Add honeypot directories to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

---

## Honeypot Artifact Generation

Use the `honeypot-deployer` CLI to generate unique artifacts:

```bash
honeypot-deployer generate --output ./artifacts --encrypt-manifest
```

### Standard Deployment Paths
The tool mimics standard wallet locations:
- **Bitcoin:** `~/.bitcoin/wallet.dat` or `%APPDATA%\Bitcoin\wallet.dat`
- **Ethereum:** `~/.ethereum/keystore/`
- **Solana:** `~/.config/solana/id.json`

---

## Browser Extension Decoys

The system generates decoys for common browser extensions by creating realistic folder structures in the local storage directories of Chrome, Edge, Brave, and Firefox.

| Extension | ID |
|-----------|----|
| MetaMask | `nkbihfbeogaeaoehlefnkodbefgpgknn` |
| Phantom | `bfnaelmomeimhlpmgjnjophhpkkoljpa` |
| TronLink | `ibnejdfjmmkpcnlpebklmnkoeoihofec` |
| Coinbase Wallet | `hnfanknocfeofbddgcijnmhnfnkdnaad` |
| Binance Wallet | `cadiboklkpojfamcoggejbbdjcoiljjk` |

---

## Deployment Verification

1. **Health Check:** `honeypot-deployer health-check --manifest ./artifacts/manifest.json`
2. **Simulation:** Access a honeyfile (e.g., `cat ~/.bitcoin/wallet.dat`) and verify a Level 12+ alert in the Wazuh dashboard.
