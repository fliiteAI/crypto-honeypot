# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to identify and track attackers at different stages of the kill chain.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense uses Wazuh's Syscheck (FIM) to monitor the honeyfiles directly.
- **Mechanism:** Wazuh `syscheck` with `realtime="yes"` and `whodata="yes"`.
- **Detections:** Any file read, modification, or deletion of the honeypot artifacts (e.g., `wallet.dat`, `id.json`, browser extension files).
- **Benefit:** High-fidelity alerts when an attacker even looks at a honeypot file.

### Layer 2: Process Auditing
This layer monitors the context around file access to identify *how* the attacker is interacting with the system.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Detections:** Identifying the specific process (e.g., `curl`, `scp`, `python`, `powershell`) that accessed the honeypot files.
- **Benefit:** Distinguishes between accidental user access and automated exfiltration or enumeration tools.

### Layer 3: Network Correlation
Monitors network activity following a honeypot trigger to detect exfiltration or C2 communication.
- **Mechanism:** Wazuh rule correlation between file access events and network connection events.
- **Detections:** Outbound connections to paste sites, IPFS, or known malicious IPs immediately following a honeypot access.
- **Benefit:** Confirms data exfiltration attempts.

### Layer 4: On-Chain Monitoring
The final layer monitors the public blockchain for any activity related to the stolen honeypot keys.
- **Mechanism:** Block explorer watchlists and automated address monitoring.
- **Detections:** An attacker importing the stolen private key into a wallet and querying the balance or attempting a transaction.
- **Benefit:** Provides definitive proof of successful theft and provides attribution if the attacker moves funds to an exchange.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

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

## Component Overview

### Honeypot Deployer (CLI)
A Python-based tool used to generate realistic, randomized wallet artifacts. It maintains an encrypted `manifest.json` that stores the generated public/private key pairs for later correlation and health checks.

### Wazuh Manager
Centralized SIEM that receives events from agents. It contains custom decoders and rules (100500+ ID range) specifically tuned for the honeypot artifacts.

### Wazuh Agent
Installed on endpoints to be monitored. It handles the FIM, process auditing (via `auditd` or `Sysmon`), and log forwarding.
