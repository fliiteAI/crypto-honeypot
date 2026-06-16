# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is designed as a multi-layered defense-in-depth system to detect, alert, and respond to attackers targeting cryptocurrency assets. The system follows a "zero false positive" philosophy, predicated on the fact that no legitimate user or process should ever access the generated honeypot files.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
This is the foundation of the system. Wazuh's FIM module monitors the honeypot files and directories for any read, modification, or deletion events.
- **Mechanism:** Wazuh FIM (`syscheck`).
- **Detection:** Any interaction with `wallet.dat`, keystores, `.env` files, or browser extension storage.
- **Alert Level:** High (Level 12+) due to the high fidelity of the signal.

### Layer 2: Process & Command Auditing
Layer 2 provides context by identifying *what* process and *which* user accessed the honeypot.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detection:** Captures the full execution path, parent processes, and command-line arguments used during the access.
- **Key Insight:** Distinguishes between automated infostealers (rapid sequential access) and manual exploration (interactive shell usage).

### Layer 3: Network Correlation
This layer detects the exfiltration phase of an attack by correlating honeypot access with suspicious network activity.
- **Mechanism:** Wazuh correlation rules and DNS monitoring.
- **Detection:**
  - Network-capable processes (e.g., `curl`, `scp`, `powershell`) accessing honeypot files.
  - DNS queries to known exfiltration sites (e.g., Pastebin, webhook.site) occurring shortly after honeypot access.
  - Usage of archive utilities (`tar`, `zip`) to stage honeypot data for exfiltration.

### Layer 4: On-Chain Monitoring
The final layer detects when an attacker successfully imports the stolen keys and interacts with them on the blockchain.
- **Mechanism:** External chain-monitor service (integrating with block explorer APIs).
- **Detection:**
  - Balance queries on honeypot addresses.
  - Outbound transfer attempts from honeypot addresses.
  - DeFi interactions (token approvals) on honeypot addresses.
- **Significance:** This provides absolute proof of compromise, even if the attacker managed to bypass host-based detections.

---

## MITRE ATT&CK Mapping

The system detects activities associated with the following MITRE ATT&CK techniques:

| ID | Technique Name | Detection Layer |
|----|----------------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 (Deletion) |
| **T1555** | Credentials from Password Stores | Layer 1 (Wallet Files) |
| **T1555.003** | Credentials from Web Browsers | Layer 1 (Extensions) |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Data Flow

1. **Honeypot-Deployer CLI** generates randomized, realistic artifacts and a manifest.
2. **Artifacts** are deployed to target endpoints.
3. **Wazuh Agent** monitors these paths via FIM and Audit rules.
4. **Wazuh Manager** receives events, decodes them, and triggers rules.
5. **Chain Monitor** (external) watches the public addresses for on-chain activity and sends logs to the Wazuh Manager for correlation.
6. **Active Response** (Optional) can trigger automated remediation, such as isolating the host or taking a forensic snapshot.
