# Architecture Overview: Crypto Wallet Honeypot

This document outlines the 4-layer detection strategy and technical design of the Crypto Wallet Honeypot system.

## Detection Strategy

The system utilizes a defense-in-depth approach with four distinct layers of detection to ensure high-fidelity alerts with zero false positives.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
This is the primary detection mechanism. Wazuh's `syscheck` module monitors honeypot files for any form of access.
- **Action:** Any read, modify, or delete operation on a honeypot file.
- **Effect:** Triggers an immediate high-severity alert (Level 12+).
- **Target:** Files like `wallet.dat`, `id.json`, and browser extension storage.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
This layer provides context by identifying *which* process accessed the honeypot files.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Value:** Differentiates between a manual user access (e.g., `cat`, `type`) and automated malware access (e.g., infostealers).

### Layer 3: Network Correlation
Monitors network activity following a honeypot access event.
- **Action:** Correlates file access with outbound network connections or use of exfiltration tools (e.g., `curl`, `scp`).
- **Value:** Confirms data exfiltration attempts.

### Layer 4: On-Chain Monitoring
The final layer tracks the movement of "stolen" assets if the attacker attempts to use the honeypot keys.
- **Mechanism:** Public addresses from the honeypot are added to block explorer watchlists (e.g., Etherscan, Solscan).
- **Value:** Provides definitive proof of theft and allows for tracking the attacker's wallet.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot detects and maps to several techniques within the MITRE ATT&CK framework:

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

## Detection Logic Flow

1. **Access:** Attacker or malware interacts with a honeypot file.
2. **Alert:** Wazuh Agent detects the event via FIM and Audit/Sysmon.
3. **Analyze:** Wazuh Manager processes the log, identifies the high-severity event, and fires a rule.
4. **Respond:** (Optional) Active Response scripts trigger forensic snapshots or account lockouts.
5. **Monitor:** On-chain watchlists alert on any movement of funds associated with the compromised keys.
