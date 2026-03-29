# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and respond to unauthorized access to cryptocurrency assets. It integrates with Wazuh SIEM to provide real-time alerting and automated response.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to ensure high-fidelity alerts and comprehensive coverage of the attack lifecycle.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** Monitors the honeypot wallet files for any read, modification, or deletion.
**What It Detects:** Direct access to honeyfiles by an attacker or automated malware (infostealers).

### Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Tracks process-level access to the honeypot file paths.
**What It Detects:** The specific process (e.g., `curl`, `python`, `powershell`) that accessed the files, providing context for the intrusion.

### Layer 3: Network Correlation
**Mechanism:** Wazuh log analysis
**Description:** Correlates file access events with subsequent network activity from the same host.
**What It Detects:** Exfiltration attempts (e.g., uploading files to a C2 server or paste site) immediately following honeypot access.

### Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain Watchlists (Etherscan, Solscan, etc.)
**Description:** Monitoring the generated honeypot public addresses for any transaction activity.
**What It Detects:** The ultimate success of the theft—when an attacker imports the stolen keys and attempts to move or query funds on the live blockchain.

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Component Diagram

1.  **Honeypot Deployer (CLI):** Generates realistic artifacts and configures the monitoring environment.
2.  **Monitored Endpoints:** Hosts where honeyfiles are placed and monitored by Wazuh Agents.
3.  **Wazuh Manager:** Centralized SIEM that receives events, applies decoders/rules, and triggers alerts.
4.  **On-Chain Watchers:** External services monitoring the public addresses associated with the honeypots.
