# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity, zero-false-positive alerts by placing decoy cryptocurrency wallet artifacts in locations where they are likely to be discovered by attackers or automated malware (infostealers).

## 4-Layer Detection Strategy

The system employs a defense-in-depth approach with four distinct detection layers.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (Syscheck)
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Details:** This is the primary trigger. Since these files are decoys and have no legitimate use, any access is considered malicious. On Linux, we use `auditd` integration for `whodata` to identify the specific user and process that accessed the file.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **What It Detects:** Process-level access to wallet paths and filesystem enumeration.
- **Details:** This layer provides context. It identifies *which* process (e.g., `python`, `curl`, `cmd.exe`) was used to access the honeypot files and tracks the sequence of commands executed by the intruder.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis & Network logs
- **What It Detects:** Exfiltration attempts (e.g., via `curl`, `scp`, or to known paste sites) occurring shortly after honeypot access.
- **Details:** By correlating file access events with outbound network connections from the same process or user, we can confirm data exfiltration in real-time.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block Explorer Watchlists (Etherscan, Solscan, etc.)
- **What It Detects:** Attacker importing stolen private keys and querying balances or attempting transfers on the blockchain.
- **Details:** Even if an attacker successfully exfiltrates the keys without being blocked, the "canary" addresses allow us to track their activity on the public blockchain.

---

## MITRE ATT&CK® Mapping

The detections provided by this system map to several techniques in the MITRE ATT&CK framework:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
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

## Design Philosophy

- **Zero False Positives:** Legitimate users and authorized system processes have no reason to access the honeypot directories. Any alert is, by definition, an unauthorized access.
- **Low Overhead:** The honeypot artifacts are small, static files. Monitoring is performed by lightweight agents (Wazuh, auditd, Sysmon).
- **Realistic Decoys:** The system generates files that mimic the exact structure and metadata of popular cryptocurrency wallets (MetaMask, Bitcoin Core, Electrum, etc.) to deceive sophisticated attackers.
