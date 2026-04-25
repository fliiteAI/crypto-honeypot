# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and alert on unauthorized access to cryptocurrency wallet artifacts. It integrates deeply with Wazuh SIEM to provide real-time monitoring and automated response.

## 4-Layer Detection Strategy

The system employs a defense-in-depth approach with four distinct detection layers.

### Layer 1: File Integrity Monitoring (FIM)
The primary detection mechanism. Wazuh's FIM module monitors the honeypot files for any access (read), modification, or deletion.
- **Mechanism:** Wazuh `syscheck`.
- **Detection:** Triggers an alert the moment an attacker or malware interacts with a honeyfile.
- **Fidelity:** Near-zero false positives, as legitimate users have no reason to access these hidden paths.

### Layer 2: Process Auditing & Behavioral Analysis
Adds context to file access by identifying *which* process accessed the honeypot.
- **Mechanism:** `auditd` (Linux) or `Sysmon` (Windows).
- **Detection:** Captures the process name, command line arguments, parent process, and user ID associated with the honeypot access.
- **Value:** Distinguishes between manual exploration (e.g., `cat`, `dir`) and automated infostealers (e.g., custom malware).

### Layer 3: Network Correlation
Monitors for data exfiltration attempts following honeypot access.
- **Mechanism:** Wazuh log analysis and network flow monitoring.
- **Detection:** Correlates file access events with subsequent outbound connections to common exfiltration targets (paste sites, C2 servers, known malicious IPs).
- **Value:** Confirms that the stolen data is being actively exfiltrated.

### Layer 4: On-Chain Monitoring
The final layer of detection, tracking the movement of funds (if any) or the import of stolen keys.
- **Mechanism:** Blockchain watchers (e.g., Etherscan, Solscan) using the public addresses from the honeypot manifest.
- **Detection:** Triggers an alert when a honeypot address is queried or used on-chain.
- **Value:** Provides definitive proof of successful theft and key compromise, even if the attacker bypasses host-based monitoring.

---

## MITRE ATT&CK Mapping

The system detects various techniques across multiple stages of the MITRE ATT&CK framework:

| ID | Technique | Layer | Description |
|----|-----------|-------|-------------|
| **T1083** | File and Directory Discovery | 1, 2 | Discovery of wallet files during enumeration. |
| **T1005** | Data from Local System | 1 | Accessing honeyfiles to steal credentials. |
| **T1555** | Credentials from Password Stores | 1 | Stealing wallet data files (e.g., `wallet.dat`). |
| **T1555.003** | Credentials from Web Browsers | 1 | Accessing browser extension local storage. |
| **T1560** | Archive Collected Data | 2, 3 | Archiving (zipping) honeyfiles before exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | 3 | Sending stolen data to a C2 server. |
| **T1048** | Exfiltration Over Alternative Protocol | 3 | Exfiltration via curl, scp, or other tools. |
| **T1657** | Financial Theft | 4 | Moving "funds" from a compromised wallet. |
| **T1070** | Indicator Removal | 1 | Deleting honeyfiles to hide tracks. |

---

## Component Integration

- **Honeypot Deployer (CLI):** Generates realistic artifacts and maintains the encrypted manifest.
- **Wazuh Agent:** Performs FIM and collects audit/Sysmon logs on the endpoints.
- **Wazuh Manager:** Processes logs, applies custom rules/decoders, and triggers alerts.
- **Wazuh Dashboard:** Provides visualization and management of security events.
- **Active Response:** (Optional) Executes automated containment actions, such as isolating the host or taking a forensic snapshot.
