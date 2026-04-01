# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles and detection strategies of the Crypto Wallet Honeypot system.

## Detection Layers

The honeypot system employs a multi-layered approach to detect both automated malware (infostealers) and manual intruders.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The foundational detection layer. Wazuh monitors for file system activity on known honeypot paths.
- **Rule ID 100501:** Wallet file accessed (Read).
- **Rule ID 100502:** Wallet file modified.
- **Rule ID 100503:** Wallet file deleted.

### Layer 2: Process-Level Auditing (Linux auditd / Windows Sysmon)
Captures *who* and *how* a honeypot was accessed, providing critical context for investigation.
- **Mechanism:** Monitors process-to-file interactions.
- **MITRE Mapping:** T1083 (File and Directory Discovery), T1005 (Data from Local System).

### Layer 3: Network Correlation
Identifies if an endpoint that recently accessed a honeypot file is now attempting to exfiltrate data.
- **Mechanism:** Correlates file access events with outbound network connections (e.g., to paste sites, curl, scp).
- **MITRE Mapping:** T1041 (Exfiltration Over C2 Channel).

### Layer 4: On-Chain Monitoring
Final verification that keys were successfully stolen and imported by an attacker.
- **Mechanism:** Tracking honeypot addresses on-chain for any movement of funds or signature activity.
- **MITRE Mapping:** T1657 (Financial Theft).

---

## MITRE ATT&CK Mapping

The system is designed to detect techniques used across the attack lifecycle:

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

---

## High-Fidelity Alerting

The honeypot works on the principle that **legitimate users never access these files**. This leads to a zero false-positive rate, making any honeypot alert a high-priority incident.
- **Automatic Containment:** Integration with Wazuh Active Response can trigger immediate endpoint isolation or user account lockout upon honeypot access.
- **Forensic Snapshot:** Automated scripts can capture process lists and memory state at the moment of detection.
