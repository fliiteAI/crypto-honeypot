# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a multi-layered defense-in-depth strategy to detect attackers targeting cryptocurrency credentials. It is specifically designed to integrate with the Wazuh SIEM platform.

## 4-Layer Detection Strategy

The system relies on four distinct layers of detection to ensure high-fidelity alerts and minimize false positives.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
This is the primary detection mechanism. Wazuh's `syscheck` module monitors the honeypot wallet files and directories. Any access (read, modify, or delete) to these files triggers an immediate alert.
- **Mechanism:** Wazuh FIM with `whodata="yes"` or `realtime="yes"`.
- **Target:** `wallet.dat`, `keystore`, `id.json`, and browser extension storage files.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
To gain visibility into *how* the files were accessed, the system utilizes OS-level auditing.
- **Linux:** `auditd` rules track the process name, user, and command line that accessed the honeypot paths.
- **Windows:** `Sysmon` events provide detailed process-level attribution, including parent process and file hash.
- **Detection:** Detects reconnaissance tools, manual exploration, and automated infostealers.

### Layer 3: Network Correlation
After an attacker accesses a wallet file, they often attempt to exfiltrate it.
- **Mechanism:** Monitoring for suspicious outbound connections (e.g., to paste sites, file sharing services, or known C2 IPs) immediately following honeypot access.
- **Correlation:** Wazuh rules correlate file access events with network activity from the same process or host.

### Layer 4: On-Chain Monitoring
The ultimate validation of a successful theft is the movement of funds or even simple "dust" transactions on the blockchain.
- **Mechanism:** Generated honeypot addresses are added to watchlists on block explorers (e.g., Etherscan, Solscan).
- **Detection:** Real-time alerts when an attacker imports the stolen private key and interacts with the blockchain.

---

## MITRE ATT&CK Mapping

The system provides coverage for several key MITRE ATT&CK techniques:

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

1. **Honeypot Deployer (CLI):** Generates randomized, realistic-looking wallet artifacts and a secure manifest.
2. **Endpoint Agent:** Wazuh Agent monitors the deployed artifacts using FIM and OS-native auditing (auditd/Sysmon).
3. **Wazuh Manager:** Receives events, applies custom decoders and rules, and triggers alerts.
4. **Active Response:** (Optional) Executes automated remediation scripts, such as taking a forensic snapshot or isolating the host.
5. **On-Chain Watcher:** (External) Monitors the public addresses for any blockchain activity.
