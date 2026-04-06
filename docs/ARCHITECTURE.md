# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide comprehensive, multi-layer detection for attackers targeting cryptocurrency assets. By deploying realistic-looking bait files across monitored endpoints, we can detect intruders at every stage of the attack lifecycle.

## 4-Layer Detection Strategy

### Layer 1: File Access Detection (Wazuh FIM)
The first line of defense uses Wazuh's File Integrity Monitoring (FIM). We configure FIM to monitor specific paths associated with cryptocurrency wallets (e.g., Bitcoin, Ethereum, Solana, and browser extensions). Any read, modification, or deletion event on these honeypot files triggers an immediate, high-fidelity alert.

- **FIM Attributes:** `realtime="yes"`, `whodata="yes"`, `check_all="yes"`, `report_changes="yes"`.
- **Target:** Detecting direct interaction with honeypot artifacts.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
Layer 2 provides context for the file access events detected in Layer 1. By integrating with `auditd` on Linux and `Sysmon` on Windows, we can identify *which* process accessed the honeypot and *how*. This helps distinguish between manual exploration and automated infostealer activity.

- **Capabilities:** Process execution tracking, command-line arguments, parent process identification.
- **Rules:** Detect rapid multi-file access (infostealer pattern) and suspicious utility usage (e.g., `find`, `grep`, `tar`).

### Layer 3: Network Correlation
Once an attacker has accessed a wallet file, they typically attempt to exfiltrate it. Layer 3 monitors for network activity that correlates with honeypot access.

- **Detections:** DNS queries to known exfiltration domains (e.g., paste sites, file upload services) or outbound connections from processes that recently touched honeypot files.

### Layer 4: On-Chain Monitoring
The final layer monitors the blockchain itself. Using the `export-addresses` command, we can retrieve the public addresses of all generated honeypots and import them into watchlists on block explorers (Etherscan, Solscan, etc.).

- **Detection:** On-chain activity (balance queries, transfers) using the stolen honeypot private keys. This provides definitive proof of compromise, even if the initial file access was not detected.

---

## MITRE ATT&CK Mapping

The system is designed to detect and alert on several MITRE ATT&CK techniques:

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
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

- **`honeypot-deployer` CLI:** The central tool for generating randomized artifacts, managing the encrypted manifest, and generating Wazuh configurations.
- **Honeypot Generators:** Specialized Python modules for creating authentic-looking wallet files for BTC, ETH, SOL, XRP, and ADA, plus BIP-39 seed phrases and browser extension decoys.
- **Wazuh Manager:** Centralized SIEM that receives events from agents, applies custom decoders and rules, and triggers alerts or active responses.
- **Wazuh Agents:** Installed on monitored endpoints to perform FIM and log collection.
