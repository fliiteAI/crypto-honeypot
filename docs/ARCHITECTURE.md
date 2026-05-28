# Architecture Overview: Crypto Wallet Honeypot

This document describes the design philosophy, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to ensure high-fidelity detection with zero false positives.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh `syscheck`
**Description:** Detects any basic filesystem interaction (Read, Write, Delete, Attribute Change) with the honeypot files.
**Detection Goal:** Early warning when an attacker or malware discovers and touches the bait files.

### Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows `Sysmon`
**Description:** Provides context on *which* process accessed the file and *who* (user) triggered the action.
**Detection Goal:** Identify the specific tool used by the attacker (e.g., `grep`, `scp`, `curl`, or a custom infostealer binary).

### Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis
**Description:** Correlates filesystem access to the honeypot with subsequent outbound network activity from the same process or host.
**Detection Goal:** Detect exfiltration attempts where the stolen data is being sent to a Command and Control (C2) server or a paste site.

### Layer 4: On-Chain Monitoring
**Mechanism:** External Block Explorer Watchlists
**Description:** Monitoring the public addresses of the generated honeypots for any activity on the blockchain.
**Detection Goal:** Final confirmation of theft. Even if the attacker bypasses host-level monitoring, their activity on the blockchain (querying balances or attempting transfers) will trigger an alert.

---

## MITRE ATT&CK Mapping

The following techniques are covered by the Crypto Wallet Honeypot detection layers:

| ID | Technique | Layer |
|----|-----------|-------|
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

## Artifact Realism

To deceive sophisticated attackers and automated malware (infostealers), the generated artifacts mimic real wallet structures:
- **Bitcoin:** Berkeley DB formatted `wallet.dat`.
- **Ethereum:** Standard UTC/JSON keystore files and `.env` files containing private keys.
- **Browser Extensions:** Realistic folder structures and LevelDB/IndexedDB files (e.g., `000003.log`, `MANIFEST-000001`).
- **Seed Phrases:** Valid BIP-39 mnemonics that pass checksum validation.

## Security and Integrity

- **Non-Funded Keys:** All generated keys are mathematically valid but contain no real assets.
- **Encrypted Manifest:** The `manifest.json` file, which tracks all generated credentials, is AES-encrypted at rest to prevent the honeypot management system itself from becoming a target.
- **Zero False Positives:** Since no legitimate user or process should ever access these specific paths, any alert triggered is a high-confidence indicator of compromise.
