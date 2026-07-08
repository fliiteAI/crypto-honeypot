# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered detection system designed to catch attackers at various stages of a cryptocurrency-focused intrusion. It follows a "zero false positive" philosophy, predicated on the fact that legitimate users and processes have no reason to interact with the honeypot artifacts.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The foundation of the system. Wazuh FIM monitors specific, realistic paths where cryptocurrency wallets are typically stored.
- **Mechanism:** Wazuh `syscheck` with `whodata` (Linux) or real-time monitoring (Windows).
- **Goal:** Detect any read, modification, or deletion of honeypot files.
- **Precision:** High. Any interaction is inherently suspicious.

### Layer 2: Process & Command Auditing
Provides context to the file access. It identifies *how* the files were accessed and by *what* process.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Goal:** Distinguish between a manual user `cat`-ing a file and an automated infostealer scanning for wallet files.
- **Precision:** Very High. Identifies the specific binary and parent process involved.

### Layer 3: Network Correlation
Correlates honeypot file access with subsequent network activity.
- **Mechanism:** Wazuh rule correlation of audit logs and network connection logs.
- **Goal:** Detect exfiltration attempts (e.g., `curl` to a paste site or `scp` to an external IP) following a honeypot access event.
- **Precision:** Critical. Confirms that stolen data is being moved out of the environment.

### Layer 4: On-Chain Monitoring
The final layer of detection that operates outside the compromised host.
- **Mechanism:** Monitoring the public blockchain for activity on the generated honeypot addresses.
- **Goal:** Detect when an attacker imports the stolen keys into their own wallet and queries the balance or attempts a transfer.
- **Precision:** Absolute. Confirms the attacker has successfully extracted and is attempting to use the keys.

---

## MITRE ATT&CK Mapping

The system's detections map to several confirmed MITRE ATT&CK techniques:

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## Zero False Positive Philosophy

The system is designed with a "zero false positive" goal. This is achieved by:
1. **Restricted Paths:** Honeypot files are placed in hidden or system-specific directories (e.g., `~/.bitcoin/wallet.dat`) that are not part of standard backup or administrative workflows.
2. **Enticing Filenames:** Names like `wallet.dat`, `id.json`, and `seed-backup.txt` are highly attractive to attackers but should be ignored by standard software.
3. **Whitelisting:** In rare cases where administrative tools (like security scanners) might trigger a hit, they can be easily whitelisted at the Wazuh Manager level.
4. **Attacker Intent:** By the time an attacker reaches Layer 4 (On-Chain Monitoring), their malicious intent is undeniable.
