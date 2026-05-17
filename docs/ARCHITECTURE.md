# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design and detection strategy of the Crypto Wallet Honeypot system.

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to ensure high-fidelity detection with zero false positives. Since legitimate users never access honeypot files, any interaction is considered malicious.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Wazuh `syscheck` module.
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Alerting:** Triggers high-severity alerts (Level 12+) immediately upon access.
- **Attributes:** Uses `whodata="yes"` on Linux (via `auditd`) and `realtime="yes"` for instant detection.

### Layer 2: Process Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **What It Detects:** The specific process and user performing the access. It captures filesystem enumeration (e.g., `ls`, `dir`) and deep inspection of wallet paths.
- **Context:** Provides the "who" and "how" behind the file access, distinguishing between automated infostealers and manual intruders.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis and network connection monitoring.
- **What It Detects:** Outbound connections to known exfiltration points (Pastebin, Telegram bots, C2 servers) or common exfiltration tools (`curl`, `wget`, `scp`) occurring shortly after honeypot access.
- **Correlation:** Links local file access to network activity to confirm successful exfiltration.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External monitoring of public blockchain addresses.
- **What It Detects:** The moment an attacker imports a stolen private key into a wallet and queries the balance or attempts a transaction.
- **Finality:** Provides 100% confirmation of a compromise even if the attacker succeeds in evading host-based detection.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot system maps to the following MITRE ATT&CK techniques:

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

## Component Interaction

1. **`honeypot-deployer` CLI:** Generates unique, randomized wallet artifacts and an encrypted manifest.
2. **Wazuh Agent:** Monitors the deployed artifacts using FIM and process auditing rules.
3. **Wazuh Manager:** Receives events, decodes them using custom decoders, and triggers alerts based on honeypot-specific rules.
4. **Active Response:** (Optional) Executes scripts on the endpoint to capture forensic snapshots or isolate the host upon detection.
5. **Chain Monitor:** (Optional) Uses the exported addresses from the manifest to monitor various blockchains for activity.
