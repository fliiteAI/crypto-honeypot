# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and infostealer malware by deploying realistic, non-funded cryptocurrency wallet artifacts across an organization's endpoints.

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to ensure that even if one detection method is bypassed, others will trigger.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (Syscheck).
- **Function:** Monitors the honeypot files for any read, modification, or deletion events.
- **Goal:** Provide immediate alerts when a honeypot file is touched. Since these are honeypots, any access is considered suspicious.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **Function:** Tracks which process and which user accessed the honeypot files.
- **Goal:** Distinguish between automated scanners (like `find` or `grep`) and targeted theft (like an infostealer or a manual operator using `scp` or `curl`). It provides critical context for incident response.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh monitoring of network-related logs and DNS queries.
- **Function:** Correlates honeypot file access with subsequent network activity, such as DNS lookups for known "paste" sites (e.g., Pastebin) or data upload services.
- **Goal:** Detect the exfiltration phase of an attack.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists and/or custom monitoring scripts.
- **Function:** Monitors the public addresses associated with the honeypot private keys for any activity on the blockchain.
- **Goal:** Detect if an attacker has successfully exfiltrated the keys and is attempting to check balances or transfer funds. This provides definitive proof of compromise.

---

## MITRE ATT&CK Mapping

The honeypot system maps to several MITRE ATT&CK techniques, providing coverage across the "Discovery", "Collection", and "Exfiltration" tactics.

| ID | Technique | Detection Layer | Description |
|----|-----------|-----------------|-------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 | Detecting tools like `find`, `ls`, or automated malware scanning for wallet paths. |
| **T1005** | Data from Local System | Layer 1 | Detecting the actual reading of wallet files or keystores. |
| **T1555** | Credentials from Password Stores | Layer 1 | Targeting of seed phrase backups or private key files. |
| **T1555.003** | Credentials from Web Browsers | Layer 1 | Targeting of browser-based wallet extensions (MetaMask, Phantom). |
| **T1560** | Archive Collected Data | Layer 2, 3 | Detecting the use of `zip`, `tar`, or `7z` shortly after honeypot access. |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 | Correlating file access with outbound network traffic from the same process. |
| **T1657** | Financial Theft | Layer 4 | Monitoring for on-chain movement of "stolen" assets. |
| **T1070** | Indicator Removal | Layer 1 | Detecting deletion of honeypot files as an attacker tries to cover their tracks. |

---

## System Components

### 1. `honeypot-deployer` CLI
The core Python application used to generate randomized, realistic artifacts and the associated encrypted manifest.

### 2. Honeypot Artifacts
The actual files (e.g., `wallet.dat`, `id.json`, `keystore`) placed on the filesystem. They are designed to match the expected structure and filenames of real wallet software.

### 3. Encrypted Manifest
A secure JSON file that stores the private keys and public addresses for all deployed honeypots. This is used for health checks and for exporting addresses to Layer 4 monitoring.

### 4. Wazuh Integration
- **Decoders:** Parse custom logs from the deployer and chain monitor.
- **Rules:** 15+ custom rules categorized by detection layer and severity.
- **Active Response:** Automated scripts that can trigger forensic snapshots or account lockouts upon honeypot access.
