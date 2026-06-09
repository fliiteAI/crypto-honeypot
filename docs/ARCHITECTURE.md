# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed as a high-fidelity, multi-layered deception system for detecting attackers and malware (info-stealers) targeting cryptocurrency assets.

## Detection Strategy: The 4-Layer Approach

Our defense-in-depth strategy ensures that an attacker is detected at multiple stages of the attack lifecycle, from initial discovery to on-chain exploitation.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **Goal:** Detect any read, modification, or deletion of honeypot artifacts.
- **Implementation:** Real-time monitoring of specific wallet directories and files (e.g., `wallet.dat`, `keystore`, `.env`).
- **Precision:** Zero false positives. Legitimate users have no reason to access these hidden, randomized files.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **Goal:** Identify the specific process and user responsible for the access.
- **Implementation:** Audit rules trigger on file access, capturing the parent process, executable path, and user ID.
- **Key Detection:** Rapid sequential access to multiple wallet paths, a hallmark of automated info-stealers.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation
- **Goal:** Detect exfiltration attempts following honeypot access.
- **Implementation:** Correlating honeypot file access with subsequent network events (e.g., `curl`, `scp`, or DNS queries to paste-sites/webhooks).
- **Key Detection:** Use of archive utilities (`zip`, `tar`) or network tools immediately after accessing a honeyfile.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block explorer watchlists & Custom Monitor
- **Goal:** Detect when an attacker imports and uses the stolen keys.
- **Implementation:** Generating real public addresses for the honeypots and monitoring them for balance queries or transactions.
- **Key Detection:** "Liveness" detection—the ultimate proof of compromise, even if the attacker successfully evaded endpoint detection.

---

## MITRE ATT&CK Mapping

The system detects techniques across several stages of the ATT&CK framework:

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

## Design Philosophy: Zero False Positives

The system is built on the core principle that **no authorized user or process should ever touch the honeypot files.**

1. **Randomization:** Artifacts are placed in plausible but non-standard locations or standard locations for wallets that *should not exist* on that system.
2. **Deception:** Files use realistic naming conventions and internal structures to fool automated scanners.
3. **Isolation:** The honeypot keys are strictly for detection and never hold real assets.

By ensuring that any access is inherently suspicious, we can set high-severity alerts (Wazuh Level 12+) that demand immediate investigation, reducing alert fatigue for security teams.
