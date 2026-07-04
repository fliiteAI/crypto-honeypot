# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed as a high-fidelity detection system for SMB environments. It follows a "zero false positive" philosophy, predicated on the fact that legitimate users and authorized processes have no reason to access the generated honeypot files.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to ensure comprehensive coverage against various attack vectors, from automated infostealers to manual lateral movement.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (Syscheck)
- **Description:** Monitors honeypot file paths for any read, modify, or delete operations.
- **Goal:** Provide the initial alert when a honeypot artifact is touched.

### Layer 2: Process and Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **Description:** Tracks which process and user accessed the honeypot files. On Linux, we use `whodata` mode via `auditd` for high-fidelity attribution.
- **Goal:** Identify the specific malware or tool used by the attacker (e.g., `python3`, `curl`, `powershell.exe`).

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation
- **Description:** Correlates honeypot file access with subsequent outbound network activity from the same host.
- **Goal:** Detect exfiltration attempts to C2 servers, paste sites, or file-sharing services.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Public Block Explorer Watchlists / On-chain scripts
- **Description:** Monitoring the generated public addresses for any activity (incoming/outgoing transfers).
- **Goal:** Detect when an attacker successfully imports the stolen keys and attempts to move funds or probe the balance, even if the initial theft went undetected.

## Zero False Positive Philosophy

Most security alerts require complex tuning to reduce noise. This honeypot system is different:
- **No Legitimate Use:** No business process or user should ever read `~/.bitcoin/wallet.dat` if they aren't using Bitcoin Core on that machine.
- **Deterministic Alerts:** Any access is, by definition, unauthorized or highly suspicious.
- **High-Severity:** Alerts are assigned high severity (Level 12-15) because they represent a direct interaction with sensitive (fake) credentials.

## MITRE ATT&CK Mapping

| Technique | Name | Layer | Description |
|-----------|------|-------|-------------|
| **T1083** | File and Directory Discovery | 1, 2 | Detecting attackers scanning for wallet files. |
| **T1005** | Data from Local System | 1 | Accessing files to collect sensitive data. |
| **T1555** | Credentials from Password Stores | 1 | Targeting localized credential stores (wallets). |
| **T1555.003** | Credentials from Web Browsers | 1 | Targeting browser-based wallet extensions. |
| **T1560** | Archive Collected Data | 2, 3 | Using `zip`, `tar`, or `rar` on honeypot files. |
| **T1041** | Exfiltration Over C2 Channel | 3 | Sending stolen keys to a C2 server. |
| **T1048** | Exfiltration Over Alternative Protocol | 3 | Using `curl` or `scp` to move the data. |
| **T1657** | Financial Theft | 4 | Moving assets on-chain using stolen keys. |
| **T1070** | Indicator Removal | 1 | Attempting to delete the honeypots after theft. |
