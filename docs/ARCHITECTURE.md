# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to catch attackers at various stages of the kill chain.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The primary detection mechanism. It monitors the honeypot files for any read, write, or delete operations.
- **Mechanism:** Wazuh `syscheck` with `whodata="yes"`.
- **Detection:** Immediate alerts when a honeypot file is accessed.

### Layer 2: Process Auditing
Provides context on *how* the files were accessed and what happened next.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detection:** Identifies the specific process (e.g., `curl`, `python`, `scp`) and user account that accessed the honeypot.

### Layer 3: Network Correlation
Monitors for exfiltration attempts or communication with known malicious infrastructure following a honeypot trigger.
- **Mechanism:** Correlation of FIM alerts with network connection logs.
- **Detection:** Alerts on data exfiltration patterns or suspicious outbound connections.

### Layer 4: On-Chain Monitoring
The final line of defense. Detects if an attacker successfully exfiltrated a private key and attempted to use it on a blockchain.
- **Mechanism:** Block explorer watchlists (e.g., Etherscan, Solscan).
- **Detection:** Real-time alerts when funds are moved to or from a honeypot address.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

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
