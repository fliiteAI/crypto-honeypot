# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed as a multi-layered detection system that mimics realistic cryptocurrency wallet artifacts. By deploying these artifacts across monitored endpoints, the system provides high-fidelity alerts when attackers or automated malware attempt to steal digital assets.

## 4-Layer Detection Strategy

The system employs a defense-in-depth approach with four distinct detection layers:

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The primary detection mechanism. Wazuh's `syscheck` (FIM) monitors the honeypot files for any access, modification, or deletion.
- **Mechanism:** Real-time monitoring of specific wallet file paths.
- **What It Detects:** Any interaction with the honeyfiles by an attacker or malware.
- **Fidelity:** Very high. Legitimate users have no reason to access these hidden/restricted directories.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
Provides context to the file access by identifying *which* process and *which* user accessed the files.
- **Mechanism:** `auditd` rules on Linux and Sysmon event logs on Windows.
- **What It Detects:** Process-level access, filesystem enumeration, and the use of tools like `grep`, `find`, or archive utilities (`zip`, `tar`) on honeypot paths.
- **Remediation:** Can trigger Wazuh Active Response to isolate the process or lock the user account.

### Layer 3: Network Correlation
Correlates honeypot file access with subsequent network activity.
- **Mechanism:** Monitoring for outbound connections to common exfiltration targets (paste sites, C2 servers, block explorers) following a honeypot trigger.
- **What It Detects:** Data exfiltration attempts via `curl`, `scp`, or dedicated malware communication channels.

### Layer 4: On-Chain Monitoring
The final line of defense. Detects when an attacker successfully imports the stolen (honeypot) keys into a real wallet and interacts with the blockchain.
- **Mechanism:** External monitoring of the honeypot's public addresses using block explorer APIs or watchlists.
- **What It Detects:** Balance queries, nonce updates, or transfer attempts on the actual blockchain.

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

## Component Interaction

1. **Honeypot Deployer (CLI):** Generates randomized, realistic wallet artifacts and an encrypted manifest.
2. **Wazuh Agent:** Monitors the deployed artifacts and sends events to the manager.
3. **Wazuh Manager:** Processes events using custom decoders and rules, triggering alerts and optional active responses.
4. **On-Chain Watcher:** (External) Monitors the public addresses for activity.
