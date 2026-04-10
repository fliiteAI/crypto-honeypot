# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity, zero-false-positive detection of attackers targeting cryptocurrency assets. It employs a multi-layered defense-in-depth strategy integrated with Wazuh SIEM.

## 4-Layer Detection Strategy

The system monitors for attacker activity across four distinct layers of the attack lifecycle:

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **What It Detects:** Any read, modification, or deletion of the generated honeypot wallet files.
- **Goal:** Provide immediate alerts when an attacker discovers and interacts with decoy wallet artifacts.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **What It Detects:** Process-level access to honeypot paths, filesystem enumeration (e.g., `find`, `ls`, `dir`), and rapid multi-file access patterns typical of infostealers.
- **Goal:** Identify the specific tools and commands the attacker is using to locate and steal credentials.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation
- **What It Detects:** Network-capable processes (e.g., `curl`, `scp`, `python`) accessing honeypot files, or DNS queries to known exfiltration/paste sites following a honeypot access event.
- **Goal:** Detect the exfiltration phase of an attack.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External chain-monitor service (using exported addresses)
- **What It Detects:** Attacker importing stolen keys into a wallet and performing on-chain activities (balance queries, transfers, token approvals).
- **Goal:** Confirm a successful compromise and track the movement of "stolen" assets, even after the attacker has left the local environment.

## MITRE ATT&CK Mapping

The honeypot detections map to the following MITRE ATT&CK® techniques:

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Component Overview

1. **honeypot-deployer (CLI):** Python-based tool for generating realistic artifacts and Wazuh configurations.
2. **Honeypot Artifacts:** Randomized, non-funded wallet files, seed phrases, and browser decoys.
3. **Encrypted Manifest:** A secure record of all deployed honeypots and their corresponding private keys (for on-chain monitoring).
4. **Wazuh Rules/Decoders:** Custom SIEM logic for processing honeypot-related events.
5. **Active Response:** Automated scripts to capture forensic snapshots (e.g., process trees, network connections) upon detection.
