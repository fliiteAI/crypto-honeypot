# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection strategy, and security philosophy of the Crypto Wallet Honeypot system.

## Detection Strategy: The 4-Layer Approach

The system employs a multi-layered defense-in-depth strategy to detect attackers at different stages of the kill chain.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) monitored in real-time.
- **Detection:** Any read, modification, or deletion of honeypot wallet files.
- **Goal:** Provide the initial alert when an attacker or malware interacts with the bait.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detection:** Captures the specific process name, user, and command-line arguments used to access the honeypot.
- **Goal:** Distinguish between automated scanners (like `find` or `grep`) and manual interaction, and identify the specific tool used by the attacker.

### Layer 3: Network Correlation
- **Mechanism:** Correlating honeypot file access with network activity (DNS queries, outbound connections).
- **Detection:** Detects exfiltration attempts to known paste sites or C2 servers immediately following honeypot interaction.
- **Goal:** Identify the exfiltration stage of an attack.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists for the generated public addresses.
- **Detection:** Alerts when the "stolen" keys are used on-chain (balance queries, transfers).
- **Goal:** Provide definitive proof of theft and track the movement of "stolen" funds (even if they are $0 bait).

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

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

## Zero False Positive Philosophy

The core design principle of this system is **zero false positives**.

Unlike traditional IDS/IPS that rely on fuzzy signatures, this honeypot relies on a simple rule: **No legitimate user or authorized process has any reason to access these specific hidden files.**

Any interaction with the honeypot artifacts is, by definition, unauthorized and suspicious. This allows security teams to treat honeypot alerts with the highest priority and confidence.
