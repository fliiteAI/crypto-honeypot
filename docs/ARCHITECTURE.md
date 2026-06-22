# Architecture Overview

The Crypto Wallet Honeypot is designed as a multi-layered detection system for identifying and alerting on malicious activity targeting cryptocurrency credentials.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to provide comprehensive coverage and defense-in-depth.

### Layer 1: File Integrity Monitoring (FIM)
This layer uses Wazuh's FIM capabilities to monitor the honeypot files themselves. Any attempt to read, modify, or delete a honeyfile triggers an immediate alert.
- **Zero False Positive Philosophy:** Legitimate users and authorized processes have no reason to access these specifically placed honeypot files. Any access is considered suspicious.

### Layer 2: Process & Command Auditing
Leveraging `auditd` on Linux and Sysmon on Windows, this layer provides visibility into *which* process accessed the honeypot and *who* (user) initiated it.
- **Detection:** It can identify rapid sequential access to multiple wallet paths, which is a classic signature of automated infostealer malware.

### Layer 3: Network Correlation
This layer correlates honeypot file access with subsequent network activity.
- **Detection:** Alerts on network-capable processes (like `curl`, `scp`, or `powershell`) accessing honeyfiles, or DNS queries to known exfiltration sites (e.g., `pastebin`, `webhook.site`) following a honeyfile access.

### Layer 4: On-Chain Monitoring
By monitoring the public addresses of the generated honeypots, we can detect if an attacker has successfully exfiltrated and imported the keys.
- **Detection:** Alerts on balance queries or outbound transfers from the honeypot addresses.

## MITRE ATT&CK Mapping

The detection capabilities map to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |
