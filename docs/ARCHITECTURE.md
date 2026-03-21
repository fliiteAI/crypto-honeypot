# Architecture: Crypto Wallet Honeypot Detection Strategy

This document describes the multi-layered detection strategy employed by the Crypto Wallet Honeypot system and how it maps to the MITRE ATT&CK framework.

## Detection Layers

The system implements a 4-layer detection strategy to ensure high-fidelity alerting and comprehensive coverage of attacker activities.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Goal:** Provide immediate, high-fidelity alerts when an attacker discovers and interacts with the bait.

### Layer 2: Process Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon
- **What It Detects:** Process-level access to wallet paths, filesystem enumeration, and use of sensitive utilities (e.g., `tar`, `zip`, `curl`) following honeypot access.
- **Goal:** Identify the specific tools and techniques used by the attacker and provide user attribution.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh rules correlating FIM events with network activity.
- **What It Detects:** Exfiltration attempts (e.g., connections to paste sites, cloud storage, or known C2 infrastructure) occurring shortly after honeypot interaction.
- **Goal:** Confirm data theft and track the destination of stolen credentials.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block explorer watchlists (Etherscan, Solscan, etc.) and custom on-chain monitoring tools.
- **What It Detects:** Attacker importing stolen keys and querying balances or attempting to move funds.
- **Goal:** Detect attacker activity even after they have left the compromised environment.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for the following MITRE ATT&CK techniques:

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

## Alert Severity Levels

The custom Wazuh rules are assigned high severity levels due to the zero-false-positive nature of honeypot interactions.

- **Level 12:** Initial access/read of a honeypot file.
- **Level 13:** Use of suspicious utilities (archiving, exfiltration) after access.
- **Level 14:** Modification or deletion of honeypot files; rapid multi-file access (infostealer pattern).
- **Level 15:** On-chain activity detected on a honeypot address; correlation of local access and on-chain movement.
