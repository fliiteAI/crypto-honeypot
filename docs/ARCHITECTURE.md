# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware (such as infostealers) that target cryptocurrency assets on compromised endpoints.

## 4-Layer Detection Strategy

The system employs a multi-layered defense-in-depth approach to ensure that if an attacker bypasses one layer, they are likely to be caught by another.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck).
- **Function:** Monitors the honeypot artifact files and directories for any access (read), modification, or deletion.
- **Alerting:** Generates high-priority alerts (Level 12+) upon any interaction, as no legitimate user or process should ever touch these decoy files.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **Function:** Provides visibility into *which* process accessed the honeypot files and *who* (user attribution) initiated the action.
- **Detection:** Identifies rapid sequential access to multiple wallet paths (typical of automated infostealers) and the use of filesystem enumeration tools (e.g., `find`, `ls`, `Get-ChildItem`) on honeypot paths.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis and network connection monitoring.
- **Function:** Correlates honeypot file access with subsequent suspicious network activity.
- **Detection:** Flags when a network-capable process (e.g., `curl`, `powershell`) accesses a honeypot, or when DNS queries to known exfiltration sites (e.g., Pastebin, Telegram API) occur shortly after a honeypot trigger.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External chain monitor service.
- **Function:** Tracks the public addresses of the generated honeypots on their respective blockchains.
- **Detection:** Triggers an alert if a "non-funded" honeypot address shows activity (balance queries, transfers), indicating the attacker has successfully exported and imported the stolen private keys/seeds into a live wallet.

---

## Data Flow

1.  **Generation:** The `honeypot-deployer` CLI generates artifacts and stores their metadata in an encrypted `manifest.json`.
2.  **Detection (Agent):** Wazuh Agent (with `auditd`/Sysmon) monitors the artifacts.
3.  **Alerting (Manager):** Wazuh Manager receives events and applies custom rules to generate alerts.
4.  **Correlation (Manager):** Correlation rules detect sophisticated attack patterns.
5.  **External Monitoring:** A separate service (or block explorer watchlists) monitors the blockchain for activity on honeypot addresses.

---

## MITRE ATT&CK Mapping

The following techniques are covered by the honeypot detection layers:

| ID | Technique | Layer |
|----|-----------|-------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |
