# Architecture Overview: Crypto Wallet Honeypot

This document describes the design philosophy and the 4-layer detection strategy of the Crypto Wallet Honeypot system.

## 4-Layer Detection Strategy

The system is designed to provide multiple opportunities to detect an attacker, from the moment they discover a honeyfile to the moment they attempt to use stolen credentials on-chain.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck).
- **Target:** Direct access to honeypot wallet files and directories.
- **Detection:** Any `open`, `modify`, or `delete` operation on a monitored path triggers a high-severity alert.
- **Goal:** Immediate detection of manual discovery or automated scanning.

### Layer 2: Process Auditing & Behavioral Analysis
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Target:** Process-level details of the access.
- **Detection:**
  - Identifies which user and which process (e.g., `curl`, `python`, `scp`) accessed the honeyfile.
  - Detects "infostealer" patterns: rapid sequential access to multiple browser extension directories.
  - Detects preparation actions, such as archiving (`tar`, `zip`) honeypot directories.
- **Goal:** Provide context and attribution for the access.

### Layer 3: Network Correlation
- **Mechanism:** Correlation of FIM events with network activity logs.
- **Target:** Data exfiltration attempts.
- **Detection:** Alerts when a process that recently accessed a honeypot file initiates an outbound network connection to a suspicious IP or a known "paste" site.
- **Goal:** Detect the exfiltration phase of an attack.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Watchlists on public block explorers (via `honeypot-deployer export-addresses`).
- **Target:** Activity on the generated public addresses.
- **Detection:** Real-time alerts (via API or email) when a honeypot address is queried on a block explorer or receives/sends a transaction.
- **Goal:** Definitive proof of credential theft and use, even if the initial breach was missed.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides coverage for the following techniques:

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
