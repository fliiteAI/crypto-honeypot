# Architecture: Crypto Wallet Honeypot

This document outlines the architectural design and detection strategy of the Crypto Wallet Honeypot system.

## Detection Strategy: The 4-Layer Model

The system employs a multi-layered detection approach to ensure high-fidelity alerts and minimize false positives. Each layer targets a different phase of an attacker's activity.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) with `whodata="yes"` and `realtime="yes"`.
- **Target:** Direct access, modification, or deletion of honeypot artifacts (e.g., `wallet.dat`, `id.json`, browser extension files).
- **Goal:** Provide the initial alert when a honeypot file is touched.

### Layer 2: Process & System Auditing
- **Mechanism:** `auditd` (Linux) and Sysmon (Windows).
- **Target:** Process-level visibility into *which* application accessed the honeypot.
- **Goal:** Distinguish between a user's browser, a command-line utility (like `cat` or `type`), or suspicious malware/infostealer processes.

### Layer 3: Network Correlation
- **Mechanism:** Correlating honeypot access alerts with network telemetry.
- **Target:** Outbound connections to known paste sites, C2 servers, or blockchain RPC nodes immediately following honeypot access.
- **Goal:** Identify exfiltration attempts and confirm the attacker's intent.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External watchlists on block explorers (Etherscan, Solscan, etc.) using the `honeypot-deployer export-addresses` command.
- **Target:** Real-time monitoring of the blockchain addresses corresponding to the generated honeypot keys.
- **Goal:** Detect if an attacker successfully imports the stolen keys and attempts to interact with the blockchain.

---

## MITRE ATT&CK Mapping

The system detects techniques across several stages of the MITRE ATT&CK framework:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## Component Overview

### 1. Honeypot Deployer CLI
A Python application responsible for:
- Generating realistic, randomized wallet artifacts.
- Managing an encrypted manifest of all deployed honeypots.
- Generating Wazuh FIM configuration snippets.
- Exporting addresses for on-chain monitoring.

### 2. Wazuh SIEM
The central management and alerting platform:
- **Manager:** Hosts custom decoders and rules for honeypot alerts.
- **Agent:** Monitors endpoints for file access and system events.

### 3. Active Response
Optional automated scripts that trigger upon honeypot access, such as:
- Performing a forensic snapshot of the system.
- Isolating the affected endpoint.
- Alerting security personnel via Slack/Email.
