# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a multi-layered defense-in-depth strategy to detect and track attackers who target cryptocurrency credentials on monitored endpoints.

## 4-Layer Detection Strategy

Our approach ensures that even if an attacker bypasses one layer of detection, subsequent actions will trigger higher-severity alerts.

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense uses Wazuh's FIM module to monitor specific filesystem paths where cryptocurrency wallets are traditionally stored.
- **Mechanism:** Wazuh `syscheck` with `whodata="yes"`.
- **Detection:** Any read, modification, or deletion of a honeypot file.
- **Value:** Provides immediate, high-fidelity alerts with zero false positives, as no legitimate process should ever access these paths.

### Layer 2: Process & Command Auditing
This layer provides deep visibility into *how* the honeypot files were accessed and what tools the attacker is using.
- **Mechanism:** `auditd` (Linux) and `Sysmon` (Windows).
- **Detection:** Captures the parent process, command-line arguments, and user attribution for every access event.
- **Value:** Detects automated infostealer behavior (e.g., rapid sequential access to multiple wallet paths) and manual enumeration (e.g., `find`, `grep`, `dir`).

### Layer 3: Network Correlation
Detects the exfiltration of stolen data by correlating honeypot access with suspicious network activity.
- **Mechanism:** Wazuh rule correlation and network log analysis.
- **Detection:** Use of network-capable tools (`curl`, `scp`, `powershell`) or DNS queries to known paste sites/API endpoints immediately following a honeypot trigger.
- **Value:** Confirms that data theft is in progress and identifies the attacker's destination.

### Layer 4: On-Chain Monitoring
The final layer tracks the movement of assets even after the attacker has successfully exfiltrated the keys.
- **Mechanism:** External chain monitoring scripts integrated with block explorer APIs.
- **Detection:** Any transaction, balance query, or token approval involving the public addresses of the generated honeypots.
- **Value:** Provides ultimate proof of compromise and allows for tracking the attacker across the blockchain.

---

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Layer |
|----|-----------|-------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## System Components

1. **Honeypot-Deployer CLI:** A Python-based tool that generates realistic wallet artifacts and encrypted manifests.
2. **Wazuh Manager:** Central SIEM that receives events, applies custom decoders and rules, and triggers alerts.
3. **Wazuh Agent:** Deployed on endpoints to perform FIM and log collection.
4. **Audit/Sysmon:** Native OS auditing tools that provide process-level context to Wazuh.
