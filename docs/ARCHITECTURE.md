# Architecture: Crypto Wallet Honeypot

This document outlines the design philosophy and detection strategy of the Crypto Wallet Honeypot system.

## Detection Strategy: The 4-Layer Model

The system employs a multi-layered detection strategy to ensure high-fidelity alerts with zero false positives. Each layer addresses a different stage of an attack.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM module.
**Detection:** Any read, modification, or deletion of honeypot wallet files.
**Philosophy:** Legitimate users and processes have no reason to access these specifically placed honeypot files. Any interaction is considered suspicious by default.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` and Windows Sysmon.
**Detection:** Tracks which process and user accessed the honeypot files.
**Value:** Provides essential context (who, what, when) and helps distinguish between a manual attacker and automated malware (e.g., rapid sequential access to multiple wallets).

### Layer 3: Network Correlation
**Mechanism:** Wazuh correlation rules.
**Detection:** Monitors for network activity (exfiltration via `curl`, `scp`, etc.) or DNS queries to paste sites immediately following honeypot file access.
**Value:** Increases alert confidence by linking file access to exfiltration behavior.

### Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain watchlists and `chain-monitor` logs.
**Detection:** Alerts when the non-funded honeypot keys are imported and used on-chain (balance queries, transfers).
**Value:** Confirms successful exfiltration and provides definitive proof of compromise, even if the initial file access was missed or obfuscated.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer | Description |
|----|-----------|-----------------|-------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 | Attacker searching for wallet files. |
| **T1005** | Data from Local System | Layer 1 | Accessing wallet files. |
| **T1555** | Credentials from Password Stores | Layer 1 | Accessing localized wallet databases. |
| **T1555.003** | Credentials from Web Browsers | Layer 1 | Accessing browser extension wallet data. |
| **T1560** | Archive Collected Data | Layer 2, 3 | Staging wallet files in a ZIP/TAR for exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 | Sending keys to an external server. |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 | Using `curl` or `scp` to move data. |
| **T1657** | Financial Theft | Layer 4 | Using stolen keys to interact with the blockchain. |
| **T1070** | Indicator Removal | Layer 1 | Attacker deleting the honeypot files after access. |

---

## Zero False Positive Philosophy

The core of this system is the **principle of zero false positives**.
1. **Isolated Paths:** Honeypot files are placed in paths where no legitimate application should be looking unless it is specifically targeting crypto wallets.
2. **Deterministic Alerts:** Because the files contain no real value and serve no functional purpose, any access is unauthorized.
3. **Contextual Enrichment:** Layer 2 and 3 ensure that alerts aren't just "file was touched" but "file was touched by `infostealer.exe` and then `curl` was used to post to a C2".
