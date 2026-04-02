# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and alert on unauthorized access to cryptocurrency wallet artifacts. By mimicking the file structures of popular crypto wallets and extensions, the system creates high-fidelity "bait" that legitimate users never access, ensuring that any interaction is a strong indicator of malicious activity.

## 4-Layer Detection Strategy

The system employs four distinct layers of detection to provide defense-in-depth and high confidence in alerts.

### Layer 1: File Integrity Monitoring (FIM)
The foundation of the system is Wazuh's File Integrity Monitoring (FIM). It monitors the honeypot files for any read, modification, or deletion events.
- **Mechanism:** Wazuh `syscheck`.
- **Detection:** Any access to the randomized wallet files or browser extension directories.

### Layer 2: Process & Command Auditing
This layer provides context by identifying *which* process accessed the honeypot and *who* was the user.
- **Mechanism:** `auditd` on Linux, `Sysmon` on Windows.
- **Detection:** Captures the parent process, command-line arguments, and user attribution for the file access. This helps distinguish between manual exploration and automated malware (infostealers).

### Layer 3: Network Correlation
Detects the "what next" by monitoring for network activity following a honeypot access event.
- **Mechanism:** Monitoring for network-capable processes (e.g., `curl`, `powershell`) and DNS queries to known exfiltration sites.
- **Detection:** Correlates file access with subsequent outbound connections to paste sites, webhooks, or C2 infrastructure.

### Layer 4: On-Chain Monitoring
The final layer tracks the movement of assets if an attacker successfully imports the "stolen" keys.
- **Mechanism:** Integration with block explorers and watchlists (e.g., Etherscan, Solscan).
- **Detection:** Alerts when a honeypot address is queried or used for a transaction on the blockchain, confirming the attacker is actively using the stolen credentials.

---

## MITRE ATT&CK Mapping

The system maps its detections to the MITRE ATT&CK framework to help security teams understand the attacker's progression.

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

---

## Wazuh Alert Rules

The system includes custom Wazuh rules (ID range 100500-100549) to categorize and escalate honeypot events.

| Rule ID | Level | Description |
|---------|-------|-------------|
| 100501 | 12 | Wallet file accessed |
| 100502 | 14 | Wallet file modified |
| 100503 | 14 | Wallet file deleted |
| 100504 | 13 | Seed phrase file accessed |
| 100505 | 13 | Browser extension data accessed |
| 100510 | 10 | Audit rule triggered on honeypot path |
| 100511 | 14 | Rapid multi-file access (infostealer pattern) |
| 100520 | 14 | Network-capable process accessed honeypot |
| 100522 | 13 | Archive utility used after honeypot access |
| 100530 | 15 | On-chain activity on honeypot address |
| 100532 | 15 | Outbound transfer from honeypot address |
| 100540 | 15 | Correlated file + chain activity |
