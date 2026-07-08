# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker—whether an infostealer, malware, or a manual intruder—accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

For a deep dive into the system's design, see the [Architecture Overview](docs/ARCHITECTURE.md).

### Detection Layers

1.  **Layer 1: Wazuh FIM** - Any read/modify/delete of honeypot wallet files.
2.  **Layer 2: Process Auditing** - Process-level access via Linux `auditd` or Windows `Sysmon`.
3.  **Layer 3: Network Correlation** - Exfiltration attempts after honeypot access.
4.  **Layer 4: On-Chain Monitoring** - Attacker using stolen keys on the public blockchain.

## Quick Start

### 1. Installation

```bash
pip install .
```

### 2. Generate Honeypot Artifacts

```bash
# Generate artifacts for all supported chains
honeypot-deployer generate --output ./honeypot-artifacts
```

### 3. Deploy Wazuh Rules

Copy the custom rules and decoders to your Wazuh Manager:

```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
systemctl restart wazuh-manager
```

### 4. Configure Wazuh Agents

Generate the FIM configuration for your endpoints:

```bash
honeypot-deployer wazuh-config \
  --manifest ./honeypot-artifacts/manifest.json \
  --os linux \
  --output ./wazuh-agent-config
```

## Documentation

- **[Deployment Guide](docs/DEPLOYMENT.md):** System requirements, Wazuh setup, and OS-specific instructions.
- **[Architecture Overview](docs/ARCHITECTURE.md):** Detailed explanation of the 4-layer detection strategy and MITRE ATT&CK mapping.
- **[On-Chain Monitoring](docs/ON_CHAIN_MONITORING.md):** How to track generated addresses on the blockchain.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager)

## License

MIT
