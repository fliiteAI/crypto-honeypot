# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware (such as infostealers) that target cryptocurrency assets. The system utilizes a multi-layered defense-in-depth strategy, integrating endpoint monitoring with SIEM-based correlation and on-chain analysis.

## Detection Strategy

The system is built on the principle of "Zero False Positives": since legitimate users and authorized processes have no reason to access the honeypot files, any interaction is considered a high-confidence indicator of compromise.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM module.
- **Purpose:** Detects any read, write, or deletion of honeypot artifacts.
- **Platform Support:** Cross-platform (Linux, Windows, macOS).
- **Fidelity:** High. Uses `auditd` (Linux) or Sysmon/Kernel callbacks (Windows) for `whodata` attribution, identifying exactly which user and process accessed the file.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon.
- **Purpose:** Monitors process execution and filesystem enumeration patterns.
- **Detection:** identifies "Infostealer behavior," such as a single process rapidly scanning multiple known wallet paths (Bitcoin, Ethereum, Exodus, etc.) in a short timeframe.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh Syscheck + Audit log correlation.
- **Purpose:** Detects exfiltration attempts following honeypot access.
- **Detection:** Correlates file access events with subsequent network activity from the same process (e.g., `curl`, `wget`, `scp`) or DNS queries to known exfiltration sites (e.g., paste sites, file sharing services).

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block Explorer APIs / Watchlists.
- **Purpose:** Detects when an attacker successfully exfiltrates and uses the honeypot keys.
- **Detection:** Fires alerts when a transaction is detected on a honeypot address, indicating that the attacker has imported the stolen keys into a wallet or query its balance.

---

## MITRE ATT&CK Mapping

The system provides coverage for several key techniques used by attackers during the data collection and exfiltration phases of an attack.

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

## Data Flow

1. **Generation:** The `honeypot-deployer` CLI generates unique, randomized wallet artifacts (BTC, ETH, SOL, etc.).
2. **Deployment:** Artifacts are placed in standard locations where attackers/malware expect to find them.
3. **Monitoring:** Wazuh agents monitor these paths using FIM and process auditing.
4. **Alerting:** When access occurs, the agent sends logs to the Wazuh Manager.
5. **Correlation:** The Wazuh Manager applies custom rules to categorize the event and, if configured, triggers Active Response (e.g., forensic snapshot, account lockout).
6. **On-Chain Tracking:** Public addresses are monitored via external watchlists for activity.
