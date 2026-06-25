# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed with a 4-layer detection strategy to provide comprehensive coverage against attackers targeting cryptocurrency assets, ranging from automated infostealers to sophisticated manual intruders.

## Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
At the most basic level, any read, modification, or deletion of the honeypot wallet files triggers an alert. Since these files are decoys and have no legitimate use, any interaction is considered malicious.
- **Mechanism:** Wazuh FIM with `whodata` enabled.
- **Goal:** Real-time alerting on file access.

### Layer 2: Process & Command Auditing
We monitor which processes and users are accessing the honeypot paths. This allows us to distinguish between a user accidentally browsing a directory and a malicious process (like an infostealer) scanning for wallet files.
- **Mechanism:** Linux `auditd` / Windows Sysmon.
- **Goal:** Attribution and behavioral analysis.

### Layer 3: Network Correlation
By correlating honeypot file access with subsequent network activity (e.g., DNS queries to paste sites, use of `curl` or `scp`), we can identify exfiltration attempts in progress.
- **Mechanism:** Wazuh correlation rules and system log analysis.
- **Goal:** Detect data exfiltration.

### Layer 4: On-Chain Monitoring
If an attacker successfully exfiltrates a private key or seed phrase, they will eventually attempt to use it on-chain. We monitor the generated public addresses for any activity.
- **Mechanism:** Block explorer watchlists and custom chain monitors.
- **Goal:** Confirmation of successful theft and tracking of stolen funds.

## MITRE ATT&CK Mapping

The system's detections map to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|---|---|---|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

## Design Philosophy: Zero False Positives

The core tenet of this system is that **legitimate users and authorized processes have no reason to access the honeypot files.**

By placing decoys in standard but sensitive locations (e.g., `~/.bitcoin/wallet.dat` or browser extension directories), we ensure that any access is a high-fidelity indicator of compromise. This "zero false positive" design reduces alert fatigue and allows security teams to respond with high confidence.
