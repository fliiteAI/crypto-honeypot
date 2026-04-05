# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## 4-Layer Detection Strategy

The system uses a defense-in-depth approach to ensure that even if an attacker bypasses one layer of detection, they are caught by another.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Monitors honeypot file paths for any read, modification, or deletion activity.
- **Detections:** Instant alerts (Level 12+) when a user or process touches a honeyfile.
- **Goal:** Provide immediate notification of an attacker's presence.

### Layer 2: Process-Level Auditing (Linux `auditd` / Windows Sysmon)
- **Mechanism:** Tracks which process and user ID accessed the honeypot files.
- **Detections:** Enumeration of filesystem paths, use of archive utilities (zip, tar) on honeypot directories, and unauthorized read access by non-standard processes.
- **Goal:** Attribute the access to a specific executable and user, allowing for forensic investigation.

### Layer 3: Network Correlation
- **Mechanism:** Correlates file access events with network activity from the same host.
- **Detections:** Outbound connections to known exfiltration sites (pastebin, anonfiles) or C2 infrastructure immediately following honeypot access.
- **Goal:** Confirm data theft and identify where the stolen data is being sent.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitors the public blockchain for any activity related to the honeypot's private keys.
- **Detections:** Real-time alerts when a generated address receives funds or initiates a transfer.
- **Goal:** Final confirmation that the attacker has successfully imported the stolen keys and is attempting to use them.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides detection coverage for several MITRE ATT&CK techniques:

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

---

## Data Flow

1. **Generation:** The `honeypot-deployer` CLI creates artifacts and records the private keys in an encrypted manifest.
2. **Deployment:** Artifacts are placed in standard wallet locations on endpoints.
3. **Detection:** Wazuh Agent monitors the files and sends events to the Wazuh Manager.
4. **Alerting:** The Wazuh Manager processes events against custom rules and triggers alerts.
5. **Response:** Wazuh triggers Active Response scripts (e.g., forensic snapshotting) to gather evidence.
6. **Correlation:** The system administrator uses the exported addresses to monitor on-chain activity.
