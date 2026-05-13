# Architecture: Crypto Wallet Honeypot

This document outlines the design principles and detection strategy of the Crypto Wallet Honeypot system.

## Detection Strategy

The system uses a 4-layer detection strategy to provide defense-in-depth against attackers.

### Layer 1: File Integrity Monitoring (FIM)
Wazuh FIM (`syscheck`) monitors the specific honeypot wallet files and directories. Any access (read, write, delete) triggers an alert. Since these are honeypot files, any access is considered malicious by definition.
- **Attributes monitored:** `whodata="yes"`, `realtime="yes"`, `check_all="yes"`, `report_changes="yes"`.

### Layer 2: Process Auditing
Using `auditd` (Linux) and `Sysmon` (Windows), the system tracks which process accessed the honeypot file. This allows distinguishing between automated malware (like an infostealer) and manual interaction by an attacker.
- **Indicators:** Usage of `zip`, `tar`, `curl`, or common browser-related processes accessing the wallet paths.

### Layer 3: Network Correlation
Alerts are correlated with network activity. If a process reads a wallet file and then immediately makes an outbound connection to an unknown IP or a paste site (e.g., Pastebin), the severity of the alert is increased.

### Layer 4: On-Chain Monitoring
The final layer involves monitoring the blockchain itself. By importing the public addresses of the generated honeypots into a watchlist (e.g., Etherscan), we can detect if an attacker successfully exfiltrated the keys and attempted to use them on-chain.

---

## MITRE ATT&CK Mapping

The system is designed to detect and alert on several techniques defined in the MITRE ATT&CK framework.

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Component Overview

1. **`honeypot-deployer` CLI:** A Python application used to generate realistic, unique wallet artifacts and manage the deployment manifest.
2. **Honeypot Artifacts:** Realistic files (e.g., `wallet.dat`, `keystore/`, `.skey`) that contain randomized, non-funded private keys.
3. **Wazuh Manager:** The central SIEM that receives events, decodes them, and triggers rules based on the 4-layer strategy.
4. **Wazuh Agents:** Installed on endpoints to perform FIM and audit logging.
