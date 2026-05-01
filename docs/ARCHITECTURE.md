# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a multi-layered defense-in-depth strategy to detect and track attackers who target cryptocurrency credentials on monitored endpoints.

## 4-Layer Detection Strategy

The system relies on four distinct layers of detection to provide high-fidelity alerts and comprehensive forensic data.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **What it detects:** Any read, modification, or deletion of honeypot wallet files.
- **Goal:** Provide the initial high-fidelity trigger. Since legitimate users never access these files, any FIM event on these paths is a confirmed security incident.

### Layer 2: Process Auditing
- **Mechanism:** Linux `auditd` / Windows `Sysmon`
- **What it detects:** The specific process and user context that accessed the honeypot files.
- **Goal:** Attribution. Identifying which application (e.g., a web browser, a python script, or `curl`) or user account initiated the access.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis & Network IDS
- **What it detects:** Outbound network connections originating from the same process or host shortly after a honeypot access event.
- **Goal:** Detect exfiltration. Identifying where the stolen "credentials" are being sent (e.g., to a C2 server, a paste site, or a known malicious IP).

### Layer 4: On-Chain Monitoring
- **Mechanism:** Blockchain Watchlists (e.g., Etherscan, Solscan, Blockcypher)
- **What it detects:** Use of the generated private keys on the actual blockchain.
- **Goal:** Post-exfiltration tracking. Even if the attacker successfully exfiltrates the keys, Layer 4 detects when they attempt to check balances or move "funds" (bait) from the honeypot addresses.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

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

## Component Diagram

1. **Honeypot Deployer (CLI):** Generates randomized artifacts and encrypted manifest.
2. **Monitored Endpoint:** Hosts the honeyfiles and runs the Wazuh Agent (`auditd`/`sysmon`).
3. **Wazuh Manager:** Receives events, correlates data, and fires alerts.
4. **Blockchain Monitor:** External service monitoring honeypot addresses for activity.
