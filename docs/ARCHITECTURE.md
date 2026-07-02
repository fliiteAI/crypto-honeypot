# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is built on a defense-in-depth strategy, utilizing four distinct detection layers to ensure zero false positives and high-fidelity alerting.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The primary detection mechanism. We monitor specific paths where cryptocurrency wallets and credentials typically reside.
- **Mechanism:** Wazuh FIM (`syscheck`) with `whodata` enabled.
- **Detections:** File access (read), modification, or deletion of honeypot artifacts.
- **Zero False Positive Principle:** Legitimate users and authorized processes have no reason to access these hidden, randomized honeyfiles.

### Layer 2: Process & Command Auditing
Provides context on *how* and *by whom* the honeypot was accessed.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detections:**
  - Process name and ID (PID) of the accessor.
  - Command-line arguments used.
  - Rapid sequential access patterns characteristic of automated infostealers.
  - Filesystem enumeration (e.g., `find`, `ls -R`, `Get-ChildItem`).

### Layer 3: Network Correlation
Detects exfiltration attempts immediately following honeypot access.
- **Mechanism:** Process-to-network correlation via Wazuh and `auditd`/`sysmon`.
- **Detections:**
  - Network-capable processes (e.g., `curl`, `scp`, `python`) accessing honeypot files.
  - DNS queries to known paste sites or C2 infrastructure (e.g., `pastebin`, `transfer.sh`, `discord.com/api`) within minutes of a honeypot trigger.
  - Use of archive utilities (`zip`, `tar`, `7z`) following artifact access.

### Layer 4: On-Chain Monitoring
The final layer of confirmation, detecting when an attacker actually uses the stolen credentials.
- **Mechanism:** External chain-monitor service (tracking public addresses via block explorers).
- **Detections:**
  - Balance queries on honeypot addresses.
  - Outbound transfer attempts (active theft).
  - Token approvals (DeFi drainer activity).
- **Correlation:** Detections in this layer confirm a full compromise if they occur after a Layer 1-3 trigger.

---

## MITRE ATT&CK Mapping

The system is designed to detect techniques across multiple stages of the attack lifecycle:

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

1. **Generation:** `honeypot-deployer` CLI creates randomized artifacts and an encrypted manifest.
2. **Deployment:** Artifacts are placed on endpoints; Wazuh agents are configured to monitor those specific paths.
3. **Trigger:** An attacker/malware accesses an artifact.
4. **Logging:** `auditd`/`sysmon` captures the event; Wazuh agent sends it to the Manager.
5. **Analysis:** Wazuh Manager decodes the log and applies custom honeypot rules.
6. **Response:**
   - A high-severity alert is fired.
   - (Optional) Active Response triggers a forensic snapshot or account lockout.
   - The admin monitors the honeypot address on-chain for movement.
