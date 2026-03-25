# Architectural Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a defensive system designed to detect attackers targeting cryptocurrency assets. It provides high-fidelity alerts with zero false positives by deploying realistic, non-funded wallet artifacts that should never be accessed by legitimate users.

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to ensure robust detection of various attack patterns, from automated infostealers to manual intruders.

### Layer 1: File Integrity Monitoring (FIM)
This is the primary detection mechanism. Wazuh FIM (syscheck) monitors the honeypot files for any read, modification, or deletion events.
- **Mechanism:** Wazuh `syscheck` module.
- **What It Detects:** Any interaction with the honeypot files at the filesystem level.

### Layer 2: Process & Command Auditing
Provides deep visibility into *who* and *how* the artifacts were accessed.
- **Mechanism:** `auditd` on Linux, Sysmon on Windows.
- **What It Detects:** The specific process (e.g., `curl`, `cat`, `python`), the user account, and the commands used to interact with the honeypot. This layer is crucial for differentiating between accidental access and malicious intent.

### Layer 3: Network Correlation
Connects local file access with network activity to identify exfiltration.
- **Mechanism:** Wazuh log correlation.
- **What It Detects:** Outbound connections or DNS queries to known exfiltration sites (e.g., Pastebin, Telegram API) occurring immediately after a honeypot access event.

### Layer 4: On-Chain Monitoring
Detects when an attacker imports stolen keys and attempts to use them on a blockchain.
- **Mechanism:** `honeypot-deployer export-addresses` + external block explorer watchlists.
- **What It Detects:** Balance queries, token approvals, or transfer attempts on the generated honeypot addresses. This is the final confirmation of a successful key theft.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for the following techniques:

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
