# System Architecture: Crypto Wallet Honeypot

This document describes the design philosophy, detection strategy, and technical architecture of the Crypto Wallet Honeypot system.

## Design Philosophy

The system is built on the principle of **Zero False Positives**. Unlike traditional IDS/IPS that rely on complex heuristics, this honeypot triggers alerts based on a simple rule: **Legitimate users and authorized processes have no reason to access the honeypot files.**

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to track an attacker from initial discovery to final exfiltration and use of stolen funds.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck).
- **Target:** Direct access (read, write, delete) to honeypot files.
- **Goal:** Immediate notification when an attacker interacts with a bait file.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Target:** Process attribution and command-line arguments.
- **Goal:** Identify *who* and *how* the files were accessed. This layer distinguishes between a manual intruder using `cat` and an automated infostealer scanning for wallet files.

### Layer 3: Network Exfiltration Detection
- **Mechanism:** Correlation between FIM events and network activity.
- **Target:** Network-capable processes (curl, scp, python) or DNS queries to known exfiltration sites (pastebin, transfer.sh) following a honeypot access.
- **Goal:** Detect the moment stolen credentials are being sent out of the network.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Real-time monitoring of honeypot public addresses on the blockchain.
- **Target:** Balance queries, transfers, or token approvals on-chain.
- **Goal:** Monitor the attacker's activity even after they have successfully exfiltrated the keys and left the compromised system.

---

## Technical Components

### 1. Honeypot Deployer (CLI)
A Python-based tool that:
- Generates realistic, non-funded cryptocurrency keys and wallet artifacts.
- Manages an encrypted `manifest.json` to track all deployed honeypots.
- Generates customized Wazuh agent configurations based on actual deployment paths.

### 2. Artifact Generators
Specialized modules for different cryptocurrency formats:
- **BTC:** Berkeley DB `wallet.dat`.
- **ETH:** UTC/JSON Keystore files.
- **SOL:** `id.json` keypair files.
- **ADA:** TextEnvelope signing keys.
- **Seed Phrases:** BIP-39 mnemonic files.
- **Browser Decoys:** Mimics LevelDB (Chrome) and IndexedDB (Firefox) structures.

### 3. Wazuh SIEM Integration
- **Custom Decoders:** Parse specialized logs from the honeypot activities.
- **Detection Rules:** A comprehensive set of rules (IDs 100500-100599) mapping to various stages of an attack.
- **Active Response:** Automated scripts to perform forensic snapshots or isolate the endpoint upon high-severity alerts.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for the following MITRE ATT&CK techniques:

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

## Data Flow

1. **Generation:** `honeypot-deployer` generates artifacts and an encrypted manifest.
2. **Deployment:** Artifacts are placed on target endpoints; Wazuh and `auditd`/`Sysmon` are configured.
3. **Trigger:** An attacker accesses a file (e.g., `~/.bitcoin/wallet.dat`).
4. **Log Collection:** `auditd` generates a log entry; Wazuh Agent picks it up.
5. **Alerting:** Wazuh Manager decodes the log, matches it against honeypot rules, and triggers a high-severity alert.
6. **Response:** (Optional) Wazuh Active Response executes a forensic script to capture the state of the system.
7. **On-Chain Tracking:** If keys are used, the Chain Monitor (external integration) sends an event to Wazuh to trigger a Layer 4 alert.
