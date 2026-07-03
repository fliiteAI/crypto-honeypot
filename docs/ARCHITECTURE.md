# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense system designed to detect and respond to attackers targeting cryptocurrency assets.

## Detection Strategy

The system employs a 4-layer detection strategy to provide comprehensive coverage from initial file access to on-chain asset movement.

| Layer | Mechanism | Description |
|-------|-----------|-------------|
| **Layer 1: FIM** | Wazuh File Integrity Monitoring | Detects real-time read, write, or delete operations on honeypot files. |
| **Layer 2: Audit** | Linux Auditd / Windows Sysmon | Provides process-level attribution (which user/process accessed the file). |
| **Layer 3: Network** | Process & Network Correlation | Identifies exfiltration attempts (e.g., `curl`, `scp`) following a honeypot access. |
| **Layer 4: On-Chain** | Block Explorer Watchlists | Detects when an attacker imports a honeypot key and interacts with the blockchain. |

## "Zero False Positive" Philosophy

A core design principle of this project is the **Zero False Positive** approach.
1. **No Legitimate Use:** There is no legitimate reason for any user or authorized process to access the generated honeypot files.
2. **High-Fidelity Alerts:** Because any access is inherently suspicious, alerts are assigned high severity levels (Level 12+), enabling immediate automated response (Active Response).

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several MITRE ATT&CK techniques:

| ID | Technique | Layer |
|----|-----------|-------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Component Breakdown

### 1. `honeypot-deployer` CLI
The Python-based CLI is the engine of the system. It handles:
- **Randomized Generation:** Creating realistic BIP-39 seeds, private keys, and wallet formats (BTC, ETH, SOL, etc.).
- **Manifest Management:** Securely storing generated keys in an AES-encrypted `manifest.json`.
- **Wazuh Integration:** Generating tailored FIM configurations based on the actual deployed artifact paths.

### 2. Wazuh SIEM
Wazuh acts as the central brain, collecting logs from agents and applying custom rules and decoders (ID range 100500-100599) to identify honeypot-related activity.

### 3. Active Response
The system includes automated remediation scripts (e.g., `honeypot-forensic-snapshot.sh`) that trigger upon alert, capturing the state of the machine at the time of the breach.
