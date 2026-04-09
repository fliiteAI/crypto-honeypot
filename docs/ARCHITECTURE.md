# Architecture: 4-Layer Detection Strategy

The Crypto Wallet Honeypot system employs a multi-layered detection strategy to ensure high-fidelity alerts and minimize false positives. This approach tracks an attacker's journey from initial discovery to final exfiltration and on-chain activity.

## Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh Syscheck
**Description:** The foundation of the system. We monitor specific, realistic wallet file paths (e.g., `~/.bitcoin/wallet.dat`).
**What it detects:** Any `read`, `write`, or `delete` operation on a honeypot file.
**Key Feature:** On Linux, we use `whodata="yes"` (via `auditd`) to capture the specific user and process that performed the action.

## Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows `Sysmon`
**Description:** Monitors process execution and filesystem enumeration in real-time.
**What it detects:**
- Processes scanning for multiple wallet files (infostealer behavior).
- Archive utilities (zip, tar) being used on honeypot directories.
- Shell commands used to inspect the contents of honeyfiles.

## Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis + Sysmon/Auditd
**Description:** Correlates file access with outbound network connections.
**What it detects:** A process that just accessed a honeypot file then makes an outbound connection to a suspicious IP, a paste site, or a known exfiltration endpoint.
**Significance:** This provides strong evidence of data theft (exfiltration).

## Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain Watchlists (Etherscan, Solscan, etc.)
**Description:** Monitoring the public addresses of the generated honeypot keys on the actual blockchain.
**What it detects:** An attacker importing the "stolen" private key into a real wallet and attempting to check balances or transfer funds.
**Significance:** This is the ultimate "smoking gun" that confirms the credentials were stolen and are being actively used.

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
