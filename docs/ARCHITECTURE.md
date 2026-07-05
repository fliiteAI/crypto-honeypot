# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and track attackers who target cryptocurrency assets. It integrates with Wazuh SIEM to provide high-fidelity alerts based on the principle of "zero false positives" (legitimate users have no reason to access honeypot files).

## Detection Strategy

The system utilizes a 4-layer detection strategy to provide defense-in-depth:

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense is Wazuh's FIM module. We deploy realistic-looking cryptocurrency wallet files (e.g., `wallet.dat`, `id.json`, `.skey`, keystore files) in standard locations.
- **Mechanism:** Wazuh monitors these files for any read, modification, or deletion.
- **Alerting:** High-severity alerts are triggered immediately upon access.

### Layer 2: Process & Command Auditing
Beyond just knowing a file was accessed, we need to know *how* and by *whom*.
- **Mechanism:** On Linux, we use `auditd` rules. On Windows, we use `Sysmon`.
- **Insight:** This layer captures the parent process, command-line arguments, and the specific user account that triggered the access. It helps distinguish between a manual attacker using `cat` and an automated infostealer scanning for wallet files.

### Layer 3: Network Correlation
Most attackers who steal wallet files will immediately attempt to exfiltrate them.
- **Mechanism:** The system correlates honeypot file access with suspicious network activity.
- **Detections:** Use of `curl`, `scp`, or `nc` immediately after accessing a honeyfile, or DNS queries to known exfiltration domains (e.g., paste sites, file sharing services).

### Layer 4: On-Chain Monitoring
The final layer tracks the "prize" itself.
- **Mechanism:** Public addresses associated with the honeypot private keys are added to watchlists on block explorers or custom monitoring services.
- **Action:** If an attacker imports the stolen keys and checks the balance or attempts a transaction, an out-of-band alert is triggered and fed back into Wazuh.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several techniques defined in the MITRE ATT&CK framework:

| ID | Technique | Layer |
|---|---|---|
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## Zero False Positive Design

The core philosophy of this system is that **no legitimate user or process should ever touch these files.**

By placing the honeypot files in paths that mimic real wallet installations (e.g., `~/.bitcoin/wallet.dat`) but ensuring they are not part of any authorized software's configuration, we ensure that any access is inherently suspicious. This allow us to set extremely high alert levels (Level 12-15) and even trigger automated active responses (like user lockout or forensic snapshots) with high confidence.
