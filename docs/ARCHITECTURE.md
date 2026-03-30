# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity, early-warning detection of attackers targeting cryptocurrency assets. It uses a multi-layered detection strategy to ensure that any interaction with the honeypot artifacts is captured and alerted on.

## Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM (File Integrity Monitoring) | Any read/modify/delete of honeypot wallet files |
| **Layer 2** | Linux auditd / Windows Sysmon | Process-level access to wallet paths, filesystem enumeration |
| **Layer 3** | Network correlation | Exfiltration attempts (curl, scp, paste sites) after wallet access |
| **Layer 4** | On-chain monitoring | Attacker importing stolen keys and querying/using them on-chain |

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense is Wazuh's FIM module. It monitors specific directories and files for any access or changes. Since these are honeypot files, any access is considered unauthorized and triggers an alert.

### Layer 2: Process & Command Auditing
To provide more context to the alerts, the system uses OS-level auditing tools (`auditd` on Linux and `Sysmon` on Windows). This allows the system to identify exactly which process and user accessed the honeypot artifacts.

### Layer 3: Network Correlation
The system can correlate honeypot access with subsequent network activity. For example, if a process accesses a wallet file and then immediately makes a network connection to a known exfiltration site (like Pastebin), it's a strong indicator of an infostealer.

### Layer 4: On-Chain Monitoring
By tracking the public addresses associated with the honeypot keys, the system can detect when an attacker imports the stolen keys into their own wallet or tries to perform transactions on the blockchain.

## MITRE ATT&CK Mapping

The system's detections are mapped to several MITRE ATT&CK techniques:

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

## Components

1.  **Honeypot Deployer CLI:** A Python application used to generate artifacts, manage the encrypted manifest, and generate Wazuh configurations.
2.  **Wazuh Manager:** The central SIEM that receives logs, parses them using custom decoders, and triggers alerts based on custom rules.
3.  **Wazuh Agent:** Installed on monitored endpoints to perform FIM and log collection.
4.  **Chain Monitor (Optional):** A service that monitors the blockchain for activity on honeypot addresses.
