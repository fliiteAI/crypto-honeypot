# Architecture Overview: Crypto Wallet Honeypot

This document outlines the 4-layer detection strategy and the system architecture of the Crypto Wallet Honeypot.

## 4-Layer Detection Strategy

The system is designed to detect attackers at various stages of an intrusion, from initial discovery to successful exfiltration and utilization of stolen assets.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** This layer detects any interaction with the honeypot files. Since these files are placed in locations that legitimate users or processes should never access, any FIM event (read, write, delete) is a high-fidelity indicator of malicious activity.
**Key Features:**
- Real-time detection.
- Monitoring of common wallet paths (e.g., `~/.bitcoin/wallet.dat`, `%APPDATA%\Ethereum\keystore`).
- Low overhead.

### Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** This layer provides context to the FIM alerts by identifying *which process* and *which user* accessed the honeypot files.
**Key Features:**
- User attribution (knowing exactly who ran the command).
- Parent process tracking (detecting if a script or a shell was used).
- Command-line argument capture.

### Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis & Network Monitoring
**Description:** This layer correlates honeypot file access with subsequent network activity. For example, if a process reads a wallet file and then immediately makes an outbound connection to a paste site or a known C2 server, the alert severity is escalated.
**Key Features:**
- Detection of data exfiltration (T1041, T1048).
- Correlation of local events with network logs.

### Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain Watchlists / Explorer APIs
**Description:** The final layer of defense. If an attacker successfully exfiltrates the honeypot private keys and imports them into a wallet, any on-chain activity (e.g., checking balances, attempting transfers) will trigger alerts.
**Key Features:**
- Detection even if the attacker bypasses all endpoint security.
- Monitoring of public addresses associated with the honeypot keys.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides coverage for several MITRE ATT&CK techniques:

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
| **T1005** | Data from Local System | Layer 1, 2 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## System Components

1.  **Honeypot Deployer (CLI):** A Python application used to generate unique, randomized honeyfiles and the corresponding Wazuh configurations.
2.  **Honeypot Artifacts:** The actual files (e.g., `wallet.dat`, `id.json`) deployed on endpoints.
3.  **Wazuh Agent:** Installed on endpoints to monitor files and processes.
4.  **Wazuh Manager:** Centralized server that receives logs, applies rules, and generates alerts.
5.  **Manifest:** An (optionally encrypted) JSON file that tracks all deployed honeypots and their private keys.
