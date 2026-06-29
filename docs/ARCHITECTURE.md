# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed for high-fidelity detection of attackers and malware (like info-stealers) targeting cryptocurrency assets. It follows a "zero false positive" philosophy, predicated on the fact that legitimate users and authorized processes have no reason to access the specifically placed honeypot files.

## 4-Layer Detection Strategy

The system employs a multi-layered defense-in-depth strategy to ensure that even if one detection method is bypassed, others will trigger.

### Layer 1: File Integrity Monitoring (FIM)
This is the primary detection layer. Using Wazuh's FIM capabilities, any access (read, modify, or delete) to the honeypot files is immediately flagged.
- **Mechanism:** Wazuh FIM.
- **What It Detects:** Direct interaction with honeyfiles like `wallet.dat`, `id.json`, or `.seed_phrase`.

### Layer 2: Process & Command Auditing
Going beyond simple file access, this layer identifies *what* process or user is accessing the honeypot.
- **Mechanism:** `auditd` on Linux (with `whodata` enabled) and `Sysmon` on Windows.
- **What It Detects:** Process-level attribution, sequential access to multiple wallets (infostealer behavior), and filesystem enumeration tools.

### Layer 3: Network Correlation
Detects the exfiltration of stolen data by correlating honeypot file access with suspicious network activity.
- **Mechanism:** Wazuh log correlation and process monitoring.
- **What It Detects:** Usage of tools like `curl` or `scp` following honeypot access, and DNS queries to known exfiltration/paste sites.

### Layer 4: On-Chain Monitoring
The final layer of detection that tracks the movement of assets if the " bait" private keys or seed phrases are actually used by the attacker on the blockchain.
- **Mechanism:** External block explorer watchlists and `honeypot-deployer export-addresses`.
- **What It Detects:** Importing stolen keys, balance queries, or transfer attempts on public blockchains (BTC, ETH, SOL, etc.).

---

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

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

## Zero False Positive Design

A key architectural pillar of this project is the elimination of false positive alerts.
1. **Isolated Placement:** Honeypot files are placed in locations that standard system processes or typical user behavior should never touch.
2. **Deterministic Alerts:** Because these files contain no legitimate data, any interaction is by definition suspicious.
3. **High Fidelity:** By combining FIM with process auditing, we can distinguish between a user accidentally clicking a file and an automated tool systematically scanning for credentials.
