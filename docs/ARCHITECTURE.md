# System Architecture

The Crypto Wallet Honeypot Deployer implements a multi-layered defense-in-depth strategy to detect attackers targeting cryptocurrency credentials. By deploying realistic but non-funded artifacts across endpoints and monitoring them through Wazuh SIEM, the system provides high-fidelity alerts with near-zero false positives.

## Detection Strategy: The 4-Layer Model

The system operates across four distinct layers of detection, ensuring that an attacker is caught regardless of their stage in the kill chain.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Goal:** Provide the initial high-fidelity alert when a file is touched. Since no legitimate user or process should ever access these specific paths, any activity is considered malicious.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **What It Detects:** The specific process name, user ID, and parent process that accessed the honeypot files.
- **Goal:** Contextualize the FIM alert. It distinguishes between a manual intruder using `cat` or `dir` and an automated infostealer scanning multiple directories.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation and network monitoring
- **What It Detects:** Exfiltration attempts (e.g., use of `curl`, `scp`, or `python` to send data to external IPs) occurring immediately after a honeypot access event.
- **Goal:** Confirm the "theft" phase of the attack and identify the attacker's command-and-control (C2) or exfiltration infrastructure.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block explorer watchlists and custom scripts
- **What It Detects:** Attacker importing the stolen private keys into a wallet and performing on-chain actions (balance queries, transfers).
- **Goal:** Provide absolute confirmation of compromise. Even if an attacker manages to bypass host-based monitoring, their activity on the blockchain is immutable and visible.

## MITRE ATT&CK Mapping

The detections provided by this system map directly to confirmed MITRE ATT&CK techniques used by infostealers and manual intruders.

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

## Integration with Wazuh

The system leverages Wazuh's flexible architecture:
- **Decoders:** Parse raw logs from `auditd`, Sysmon, and FIM into structured data.
- **Rules:** 15+ custom rules with severity levels up to 15 (Critical) to trigger alerts.
- **Active Response:** Automated scripts that can take forensic snapshots or isolate hosts when a high-severity honeypot alert is triggered.
