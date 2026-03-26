# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect, attribute, and alert on attackers targeting cryptocurrency assets. It integrates with Wazuh SIEM to provide real-time monitoring and automated response.

## 4-Layer Detection Strategy

The system employs a defense-in-depth approach with four distinct layers of detection.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** Monitors the filesystem for any access (read), modification, or deletion of honeypot artifacts.
**Key Features:**
- Real-time alerts on file access.
- `whodata` integration for user and process attribution.
- Detection of "reconnaissance" as soon as an attacker lists or reads a honeyfile.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Provides deep visibility into the processes accessing honeypot files.
**Detection Patterns:**
- Rapid sequential access to multiple wallet paths (classic Infostealer behavior).
- Use of filesystem enumeration tools (`find`, `ls`, `Get-ChildItem`) on honeypot directories.
- Correlation of process trees to identify the parent application (e.g., a malicious downloader).

### Layer 3: Network Correlation
**Mechanism:** Wazuh + Sysmon/Socket Monitoring
**Description:** Correlates honeypot file access with subsequent network activity.
**Detection Patterns:**
- Use of exfiltration-capable tools (`curl`, `scp`, `powershell`) immediately after accessing a honeypot.
- DNS queries to known paste sites or exfiltration endpoints (`pastebin.com`, `transfer.sh`).
- Connection attempts to suspicious external IPs after honeypot interaction.

### Layer 4: On-Chain Monitoring
**Mechanism:** `chain-monitor` service (External)
**Description:** Tracks the generated honeypot addresses on their respective blockchains.
**Key Features:**
- Alerts when an attacker imports a stolen private key and performs a balance query.
- Real-time notification of outbound transfer attempts from honeypot addresses.
- Detection of "DeFi drainer" activity (token approvals).

---

## MITRE ATT&CK Mapping

The system provides coverage for several MITRE ATT&CK techniques:

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

---

## Component Diagram

1. **Honeypot Artifacts:** Realistic-looking files (e.g., `wallet.dat`, `id.json`) deployed on endpoints.
2. **Wazuh Agent:** Local monitoring agent that detects filesystem and process events.
3. **Wazuh Manager:** Centralized SIEM that processes events, triggers rules, and sends alerts.
4. **Honeypot Manifest:** Encrypted database tracking all deployed artifacts and their associated private keys.
5. **Chain Monitor:** External service that watches the blockchain for activity on honeypot addresses.
