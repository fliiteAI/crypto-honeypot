# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to identify and track attackers from the moment they discover a decoy asset to the moment they attempt to monetize it on-chain.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The foundation of the system is high-fidelity file monitoring. Any interaction with the honeypot artifacts triggers an immediate alert.
- **Mechanism:** Wazuh `syscheck` module.
- **Attributes:** `whodata="yes"`, `realtime="yes"`, `report_changes="yes"`.
- **Detection:** Read, modify, or delete operations on wallet files, keystores, and seed phrase backups.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
Provides context to the file access by identifying the process and user responsible.
- **Mechanism:** `auditd` rules on Linux; Sysmon event logs on Windows.
- **Detection:** Specifically monitors for non-standard processes (e.g., `curl`, `scp`, `python`) accessing honeypot paths, or rapid access to multiple honeypot files (indicative of an automated infostealer).

### Layer 3: Network Correlation
Monitors for exfiltration attempts that occur shortly after honeypot access.
- **Mechanism:** Wazuh ruleset correlation.
- **Detection:** Detects patterns where a honeypot file is read followed immediately by an outbound connection to a paste site (e.g., Pastebin), a file-sharing service, or a known C2 IP.

### Layer 4: On-Chain Monitoring
The final layer tracks the movement of "stolen" credentials on the blockchain.
- **Mechanism:** Block explorer watchlists and custom monitoring scripts.
- **Detection:** Alerts when a honeypot address is queried on a block explorer or when a transaction is initiated using the honeypot's private key.

---

## MITRE ATT&CK Mapping

The system detects techniques across several stages of the ATT&CK framework:

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

## Component Interaction

1. **Honeypot Deployer CLI:** Generates unique artifacts and an encrypted manifest.
2. **Wazuh Agent:** Monitors the artifacts based on the generated FIM configuration and audit rules.
3. **Wazuh Manager:** Processes logs from agents, decodes them using custom decoders, and fires alerts based on honeypot-specific rules.
4. **Active Response:** (Optional) Executes a forensic snapshot script on the endpoint upon honeypot access.
5. **Chain Monitor:** (External) Periodically checks the blockchain for activity on the honeypot addresses exported from the manifest.
