# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and track attackers who target cryptocurrency assets. By deploying realistic "bait" files across monitored endpoints, the system provides high-fidelity alerts with zero false positives.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to ensure that even sophisticated attackers are caught at various stages of their lifecycle.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The foundation of the system. Wazuh FIM monitors the honeypot files for any access (read, modify, or delete).
- **Mechanism:** `syscheck` with `whodata="yes"` and `realtime="yes"`.
- **Detection:** Immediate alerts when a process or user touches a honeypot file.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
Provides context to the FIM alerts by identifying *which* process accessed the file and what it did next.
- **Mechanism:** `auditd` rules on Linux and Sysmon event ID 1 on Windows.
- **Detection:** Detects patterns such as directory enumeration, rapid multi-file access (typical of infostealers), and the use of archive utilities (tar, zip) after honeypot access.

### Layer 3: Network Correlation
Monitors for exfiltration attempts following a honeypot access event.
- **Mechanism:** Correlating FIM/Audit events with network connection logs (e.g., `curl` to a paste site or `scp` to an unknown IP).
- **Detection:** Identifies the "where" of data exfiltration, providing critical forensic evidence.

### Layer 4: On-Chain Monitoring
The final layer of defense. If an attacker successfully exfiltrates a private key, they will eventually attempt to use it on the blockchain.
- **Mechanism:** Monitoring the public addresses associated with the honeypot keys using block explorer watchlists or dedicated monitoring services.
- **Detection:** Detects when an attacker imports a stolen key and queries its balance or attempts a transaction, even if the endpoint detection was bypassed.

## MITRE ATT&CK Mapping

The system's detections map to several confirmed MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Component Interaction

1. **`honeypot-deployer` CLI:** Generates unique, randomized artifacts and an encrypted manifest.
2. **Wazuh Agent:** Deployed on endpoints, configured via CLI-generated snippets to monitor artifact paths.
3. **Wazuh Manager:** Processes events from agents, applies custom decoders and rules, and triggers alerts.
4. **Active Response:** (Optional) Executes automated forensic collection scripts upon high-severity honeypot alerts.
5. **Chain Monitor:** (External) Watches the blockchain for activity on generated honeypot addresses.
