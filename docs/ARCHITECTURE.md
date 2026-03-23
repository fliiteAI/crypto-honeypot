# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection layers, and threat model for the Crypto Wallet Honeypot system.

## Detection Strategy

The system utilizes a multi-layered detection approach to provide high-fidelity alerts throughout the lifecycle of an attack, from initial discovery to successful exfiltration and monetization.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh Syscheck
**Function:** Detects any read, write, or delete operations on honeypot wallet artifacts.
**Value:** Provides the earliest possible warning of an attacker or automated malware interacting with the bait.

### Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Function:** Attributes file access to a specific process and user.
**Value:** Distinguishes between manual exploration (e.g., `cat`, `dir`, `ls`) and automated infostealers (e.g., rapid multi-file access).

### Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis & Network Monitoring
**Function:** Correlates honeypot file access with subsequent network activity (e.g., HTTPS POST to a paste site or C2).
**Value:** Confirms data exfiltration and helps identify the attacker's destination.

### Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain Watchers (Etherscan, Solscan, etc.)
**Function:** Monitors the generated honeypot addresses for any balance queries or incoming/outgoing transactions.
**Value:** Detects the "monetization" phase of an attack, even if the initial breach was missed by internal sensors.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several techniques in the MITRE ATT&CK framework:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
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

## Threat Model

### Target Persona
The system is designed to detect:
1. **Automated Infostealers:** Malware that scans for common crypto wallet paths.
2. **Manual Intruders:** Human attackers exploring the filesystem for valuable data.
3. **Malicious Insiders:** Employees or contractors searching for secrets.

### Assumptions
- **Legitimate users never access honeypot files.** This ensures a near-zero false positive rate.
- **Attackers prioritize crypto assets.** High-value targets are more likely to be targeted by specialized wallet-hunting malware.
