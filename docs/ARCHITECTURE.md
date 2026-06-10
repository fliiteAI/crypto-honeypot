# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is built on a "zero false positive" philosophy. Legitimate users and authorized processes have no reason to access the generated honeypot files. Any interaction with these artifacts is therefore treated as high-fidelity evidence of malicious activity.

## 4-Layer Detection Strategy

The system employs four distinct layers of detection to provide defense-in-depth and correlate attacker behavior from initial discovery to on-chain theft.

### Layer 1: File Integrity Monitoring (FIM)
This is the primary detection mechanism. Wazuh FIM (syscheck) monitors the honeypot files for any read, modification, or deletion.
- **Mechanism:** Wazuh Agent `syscheck`.
- **Target:** Wallet files (`wallet.dat`, `id.json`, etc.), seed phrase backups, and browser extension storage.
- **Detection:** Any file system event on a monitored path.

### Layer 2: Process & Command Auditing
Provides visibility into *how* the files were accessed and by whom.
- **Mechanism:** `auditd` (Linux) or Sysmon (Windows).
- **Target:** Process executions and command-line arguments targeting honeypot paths.
- **Detection:** Use of tools like `cat`, `grep`, `find`, or custom infostealer malware accessing the directories.

### Layer 3: Network Correlation
Detects exfiltration attempts following honeypot access.
- **Mechanism:** Network connection logs and DNS query monitoring.
- **Target:** Processes that accessed honeypot files then making outbound connections or DNS queries to paste sites (e.g., Pastebin) or exfiltration endpoints.
- **Detection:** Correlation between Layer 1/2 events and outbound network activity.

### Layer 4: On-Chain Monitoring
The final layer of detection that tracks the use of the non-funded keys by the attacker.
- **Mechanism:** External chain monitors (e.g., Etherscan watchlists, custom scripts).
- **Target:** The public addresses corresponding to the deployed honeypot private keys.
- **Detection:** Balance queries, token approvals, or transaction attempts on the blockchain.

---

## MITRE ATT&CK Mapping

The detections provided by this system map directly to various techniques in the MITRE ATT&CK framework:

| ID | Technique Name | Detection Layer |
|----|----------------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Component Interaction

1. **Honeypot Deployer CLI:** Generates unique artifacts and their corresponding public/private keys.
2. **Encrypted Manifest:** Stores all generated key data securely.
3. **Wazuh Manager:** Receives events, applies custom decoders and rules, and triggers alerts.
4. **Wazuh Agent:** Performs real-time monitoring on endpoints via FIM and Audit/Sysmon.
5. **Chain Monitor:** (External) Polls block explorers for activity on honeypot addresses.
