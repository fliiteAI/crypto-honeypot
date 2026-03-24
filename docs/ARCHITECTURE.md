# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design and detection strategy of the Crypto Wallet Honeypot system.

## Detection Strategy

The system utilizes a 4-layer detection strategy to provide high-fidelity alerts with zero false positives.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Monitors honeypot wallet files for any read, modify, or delete operations.
- **Goal:** Detect the initial access to the honeypot artifacts.
- **Attributes:** Configured with `realtime="yes"`, `whodata="yes"`, `check_all="yes"`, and `report_changes="yes"`.

### Layer 2: Process Auditing (Linux auditd / Windows Sysmon)
- **Mechanism:** Tracks process-level access to honeypot paths and filesystem enumeration.
- **Goal:** Identify the specific process and user responsible for accessing the honeypot files.
- **Linux:** Uses `auditd` rules (e.g., `-p r -k crypto_honeypot`) for high-fidelity read-access detection.
- **Windows:** Leverages Sysmon for detailed process and file event logging.

### Layer 3: Network Correlation
- **Mechanism:** Correlates honeypot file access with subsequent network activity (e.g., use of `curl`, `scp`, or access to paste sites).
- **Goal:** Detect exfiltration attempts following a honeypot compromise.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitors the public addresses of the generated honeypot wallets on their respective blockchains.
- **Goal:** Detect when an attacker imports the stolen keys and performs on-chain actions (queries or transfers).
- **Tools:** Integration with block explorer watchlists (Etherscan, Solscan, etc.).

## MITRE ATT&CK Mapping

The system's detections map to the following MITRE ATT&CK techniques:

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## System Components

1. **Honeypot Deployer (CLI):** Python-based tool for generating randomized, realistic wallet artifacts and managing the encrypted manifest.
2. **Wazuh Manager:** Centralized SIEM that receives logs from agents, applies custom decoders and rules, and triggers alerts or active responses.
3. **Wazuh Agent:** Installed on monitored endpoints to perform FIM and log collection.
4. **Active Response:** Automated scripts on the Wazuh Manager that can trigger remediation actions (e.g., forensic snapshots or account lockouts) upon honeypot access.
