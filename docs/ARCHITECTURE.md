# System Architecture

The Crypto Wallet Honeypot is designed as a multi-layered defense system integrated with Wazuh SIEM to detect and alert on unauthorized access to cryptocurrency assets.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to ensure high-fidelity alerts and comprehensive coverage of the attack lifecycle.

### Layer 1: File Integrity Monitoring (FIM)
Wazuh FIM (syscheck) is the primary detection mechanism. It monitors specific filesystem paths where crypto wallets are traditionally stored.
- **Real-time Detection:** Alerts are generated immediately upon file access (read), modification, or deletion.
- **Whodata (Linux):** On Linux, `auditd` integration provides "whodata," which includes the user ID and process name that accessed the honeypot.
- **Attribute Monitoring:** Tracks changes to file permissions and ownership.

### Layer 2: Process & System Auditing
This layer provides context beyond simple file access by monitoring process-level activity.
- **Linux Auditd:** Custom audit rules capture detailed system calls related to honeypot paths.
- **Windows Sysmon:** Monitors process creation, network connections, and file events, allowing us to see *which* application (e.g., a browser, a script, or a malware executable) interacted with the honeyfile.
- **Triage:** Distinguishes between accidental user access and automated malware scanning.

### Layer 3: Network Correlation
Detects the "Exfiltration" phase of an attack.
- **Post-Access Network Activity:** Monitors for network connections made by a process shortly after it has touched a honeypot file.
- **Known Exfiltration Tools:** Alerts on the use of `curl`, `wget`, `scp`, or `ftp` in conjunction with honeypot access.
- **Data Compression:** Monitors for the creation of archive files (zip, tar, 7z) containing honeypot paths.

### Layer 4: On-Chain Monitoring
The "Ultimate Source of Truth." If an attacker successfully exfiltrates a private key, they will eventually import it and check for funds or attempt a transaction.
- **Public Address Monitoring:** The public addresses associated with the honeypot keys are added to watchlists on block explorers (Etherscan, Solscan, etc.).
- **Real-time Alerts:** Triggered when the honeypot address is queried or involved in a transaction on the blockchain.
- **Correlation:** Wazuh correlates on-chain activity with local endpoint alerts for a complete picture of the breach.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several techniques in the MITRE ATT&CK framework:

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

## Component Overview

### Honeypot Deployer CLI
A Python-based utility that generates randomized, realistic crypto artifacts (BTC `wallet.dat`, ETH Keystores, etc.) and manages a secure manifest of the generated keys.

### Wazuh Ruleset
A collection of custom XML decoders and rules (100500+ ID range) that process logs from FIM, Auditd, and Sysmon to generate high-severity alerts.

### Active Response
Automated scripts that can be triggered by the Wazuh Manager to perform actions like locking a user account or taking a forensic snapshot of the endpoint upon honeypot access.
