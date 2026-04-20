# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity, zero-false-positive detection of attackers targeting cryptocurrency assets on monitored endpoints. It achieves this through a multi-layered detection strategy integrated with Wazuh SIEM.

## 4-Layer Detection Strategy

The system employs four distinct layers of detection to ensure that an attacker is caught at multiple stages of their operation.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** This is the primary detection layer. It monitors the specific paths where cryptocurrency wallet artifacts (e.g., `wallet.dat`, `keystore` files, `.env` files) are deployed.
**Detections:**
- **Read Access:** Detects when a process reads a honeypot file.
- **Modification:** Detects attempts to modify or inject data into honeypot files.
- **Deletion:** Detects when an attacker deletes honeypot files to cover their tracks.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** This layer provides context to the file access events. It captures *who* accessed the file and *what* process was used.
**Detections:**
- **User Attribution:** Identifies the local user account responsible for the access.
- **Process Identification:** Identifies the specific binary (e.g., `python`, `cat`, `explorer.exe`) that accessed the honeypot.
- **Infostealer Patterns:** Detects rapid, sequential access to multiple wallet paths, characteristic of automated infostealer malware.

### Layer 3: Network Correlation
**Mechanism:** Wazuh Network Monitoring / DNS Logs
**Description:** Correlates honeypot file access with subsequent network activity.
**Detections:**
- **Exfiltration Tools:** Detects the use of network-capable tools (e.g., `curl`, `scp`, `rsync`) following a honeypot access event.
- **Suspicious DNS Queries:** Detects DNS resolutions to known paste sites or exfiltration endpoints (e.g., `pastebin.com`, `transfer.sh`) after a honeypot hit.

### Layer 4: On-Chain Monitoring
**Mechanism:** Blockchain Watchlists / Chain Monitor Service
**Description:** The "ultimate" detection layer. If an attacker successfully exfiltrates a honeypot private key and imports it into their own wallet, any activity on the blockchain using that key will trigger an alert.
**Detections:**
- **Balance Queries:** Detects when an attacker checks the balance of a honeypot address on-chain.
- **Outbound Transfers:** Detects attempts to move "funds" from the honeypot address.
- **Contract Interactions:** Detects interactions with DeFi protocols or drainer contracts.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several MITRE ATT&CK techniques across the attack lifecycle.

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
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

## System Components

1. **Honeypot Deployer (CLI):** Generates randomized, realistic artifacts and manages the encrypted manifest.
2. **Wazuh Agent:** Installed on endpoints, performs FIM and collects audit logs.
3. **Wazuh Manager:** Centralizes logs, applies custom decoders and rules, and triggers alerts.
4. **Chain Monitor:** (Optional) Service that monitors the blockchain for activity on honeypot addresses.
5. **Active Response Scripts:** Automated scripts that can trigger forensic snapshots or account lockouts upon honeypot detection.
