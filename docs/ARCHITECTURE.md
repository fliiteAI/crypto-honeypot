# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to catch attackers at various stages of the kill chain, from initial discovery to successful exfiltration and financial theft.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The foundation of the system. It monitors the honeypot wallet files and directories for any access (read), modification, or deletion.
- **Mechanism:** Wazuh `syscheck` (FIM) with `whodata="yes"` and `realtime="yes"`.
- **Detections:** Direct interaction with honeypot files.

### Layer 2: Process Auditing
Provides deep visibility into *which* process accessed the honeypot files. This allows the system to distinguish between manual exploration (e.g., `cat`, `ls`, `type`) and automated malware (e.g., info-stealers, scripts).
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Detections:** Process-level access, parent process trees, and command-line arguments.

### Layer 3: Network Correlation
Correlates honeypot file access with subsequent network activity. If a process reads a wallet file and then immediately initiates a network connection to a suspicious IP or domain, it is flagged as high-severity exfiltration.
- **Mechanism:** Wazuh log correlation and custom rules.
- **Detections:** Exfiltration attempts (curl, scp, paste sites) after wallet access.

### Layer 4: On-Chain Monitoring
The final layer of detection. If an attacker successfully exfiltrates the keys and imports them into a wallet, any on-chain activity (balance queries, transfers) will be detected by monitoring the public addresses of the generated honeypots.
- **Mechanism:** Block explorer watchlists and `honeypot-deployer export-addresses`.
- **Detections:** Attacker importing stolen keys and using them on-chain.

---

## MITRE ATT&CK Mapping

The system is designed to detect and respond to several techniques defined in the MITRE ATT&CK framework:

| ID | Name | Layer | Description |
|----|------|-------|-------------|
| **T1083** | File and Directory Discovery | 1, 2 | Detecting attackers searching for wallet files. |
| **T1005** | Data from Local System | 1 | Detecting the actual reading of honeypot wallet data. |
| **T1555** | Credentials from Password Stores | 1 | Targeted detection of cryptocurrency wallet stores. |
| **T1555.003** | Credentials from Web Browsers | 1 | Specifically targeting browser-based wallet extensions. |
| **T1560** | Archive Collected Data | 2, 3 | Detecting the creation of archives (zip, tar) containing honeyfiles. |
| **T1041** | Exfiltration Over C2 Channel | 3 | Correlation of file access with known C2 traffic. |
| **T1048** | Exfiltration Over Alternative Protocol | 3 | Detecting exfiltration via HTTP, SCP, or other protocols. |
| **T1657** | Financial Theft | 4 | Detecting the movement of funds or on-chain interaction. |
| **T1070** | Indicator Removal | 1 | Detecting attempts to delete the honeypot files after access. |
