# Architecture Overview

The Crypto Wallet Honeypot system implements a multi-layered detection strategy designed to catch attackers at various stages of the kill chain, from initial discovery to final exfiltration and on-chain theft.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **High Fidelity:** Legitimate users and system processes should never touch these files, resulting in zero false positives.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **What It Detects:**
    - The specific process (e.g., `curl`, `python`, `zip`) that accessed the honeypot.
    - User attribution (who ran the process).
    - Rapid sequential access to multiple wallet paths, which is characteristic of automated infostealers.
    - Filesystem enumeration tools (e.g., `find`, `dir`, `Get-ChildItem`) scanning honeypot directories.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation
- **What It Detects:**
    - Network-capable processes accessing honeypots.
    - Outbound connections or DNS queries to known exfiltration sites (e.g., Pastebin, transfer.sh, Discord webhooks) immediately following a honeypot access event.
    - Staging for exfiltration, such as the use of archive utilities (`tar`, `zip`, `7z`) on honeypot data.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists + `honeypot-deployer export-addresses`
- **What It Detects:**
    - Attacker importing stolen private keys into their own wallet.
    - Balance queries on the honeypot addresses.
    - Outbound transfer attempts (theft) from the honeypot addresses.
    - This provides 100% confirmation of a successful compromise, even if the attacker successfully evaded endpoint detection.

---

## MITRE ATT&CK Mapping

The system's detections are mapped to confirmed MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1, 2 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
