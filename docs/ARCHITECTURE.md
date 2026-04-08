# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and alert on unauthorized access to cryptocurrency-related artifacts. It integrates with Wazuh SIEM to provide real-time detection and automated response.

## 4-Layer Detection Strategy

Our strategy focuses on detection at every stage of an attacker's lifecycle, from initial discovery to final exfiltration and on-chain theft.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (`syscheck`).
- **Detection:** Triggers on any access (read, write, or delete) to honeypot wallet files, seed phrases, or browser extension decoys.
- **Goal:** Provide the earliest possible alert when an attacker or malware interacts with the filesystem.

### Layer 2: Process Auditing
- **Mechanism:** `auditd` (Linux) and Sysmon (Windows).
- **Detection:** Correlates file access events with specific processes and user accounts. It tracks filesystem enumeration (e.g., `find`, `ls`, `dir`) and the use of archiving utilities (e.g., `zip`, `tar`, `7z`).
- **Goal:** Identify the tool and user responsible for the access, providing critical context for incident response.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis of system calls and network logs.
- **Detection:** Correlates honeypot file access with subsequent network activity, such as `curl` or `scp` commands, or connections to known exfiltration sites (e.g., paste sites, C2 servers).
- **Goal:** Detect the exfiltration phase of an attack.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Blockchain explorers and custom monitoring scripts.
- **Detection:** Tracks the generated honeypot addresses on-chain. Alerts are fired if an attacker imports a stolen private key and performs a balance query or an outbound transfer.
- **Goal:** Confirm the compromise of sensitive credentials even if the attacker bypasses host-based controls.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Component Overview

### Honeypot Deployer CLI
A Python-based tool used to:
1. Generate realistic, non-funded wallet artifacts.
2. Manage an encrypted manifest of all deployed honeypots.
3. Generate localized Wazuh agent configurations.
4. Export addresses for on-chain monitoring.

### Wazuh Manager
The central SIEM that:
1. Decodes incoming logs using custom regex decoders.
2. Evaluates events against a specialized honeypot rule set (IDs 100500+).
3. Triggers automated Active Response scripts for forensic snapshots.

### Wazuh Agent
Deployed on monitored endpoints to:
1. Perform real-time FIM and `whodata` monitoring.
2. Collect and forward `auditd` or Sysmon events to the manager.
