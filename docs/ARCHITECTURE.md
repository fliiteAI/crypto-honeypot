# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed as a high-fidelity, multi-layered detection system for identifying and tracking attackers targeting cryptocurrency credentials. It operates on the core principle of "Zero False Positives": legitimate users and authorized processes have no reason to access these decoy files.

## 4-Layer Detection Strategy

The system employs a defense-in-depth approach to catch attackers at various stages of their lifecycle.

### Layer 1: File Integrity Monitoring (FIM)
This is the primary detection layer. Using Wazuh's FIM (syscheck), the system monitors honeypot files for any access (Read, Write, or Delete).
- **Mechanism:** Wazuh `syscheck` with `realtime` and `whodata` enabled.
- **Alerting:** Fires high-severity alerts (Level 12-14) immediately upon interaction.
- **Detection:** Infostealers scanning the filesystem or manual intruders browsing directories.

### Layer 2: Process and Command Auditing
This layer provides context by identifying *which* process or command was used to access the honeypot.
- **Mechanism:** Linux `auditd` rules and Windows `Sysmon`.
- **Alerting:** Correlates file access events with process execution logs.
- **Detection:** Use of tools like `cat`, `scp`, `curl`, or specialized infostealer binaries. Rapid multi-file access patterns are flagged as automated malware behavior.

### Layer 3: Network Correlation
Detects the exfiltration of stolen data by monitoring network connections initiated by processes that recently touched a honeypot file.
- **Mechanism:** Wazuh's correlation engine matching process IDs and network events.
- **Alerting:** High-severity alerts when a process that accessed a wallet file connects to a remote IP or domain (e.g., paste sites, C2 servers).
- **Detection:** Data exfiltration via `curl`, `ftp`, or custom malware backchannels.

### Layer 4: On-Chain Monitoring
The final layer of detection occurs after the data has been stolen and imported into an attacker's wallet.
- **Mechanism:** External chain-monitoring services (e.g., Etherscan/Solscan watchlists) or the `honeypot-deployer export-addresses` tool.
- **Alerting:** Alerts when the honeypot addresses are queried on-chain or when funds are moved to/from them.
- **Detection:** Attacker verifying the balance of stolen keys or preparing for a transaction.

---

## MITRE ATT&CK® Mapping

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
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

## Zero False Positive Design

The honeypot is deployed to locations that are standard for crypto wallets (e.g., `~/.bitcoin/`, `%APPDATA%\Ethereum\`) but are deliberately not used by the legitimate system owner. This ensures that any alert generated is actionable and indicative of malicious activity, reducing alert fatigue for security teams.
