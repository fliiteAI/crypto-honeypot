# Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a defensive security system designed to detect and respond to unauthorized access of cryptocurrency-related assets on monitored endpoints. It employs a multi-layered detection strategy to ensure high-fidelity alerts with zero false positives.

## Detection Strategy

The system relies on the principle that **legitimate users never access honeypot files**. Any access, therefore, is indicative of malicious activity, whether by an automated infostealer, a manual intruder, or compromised software.

### The 4-Layer Detection Model

| Layer | Mechanism | Scope |
|-------|-----------|-------|
| **Layer 1: File Integrity Monitoring (FIM)** | Wazuh FIM (syscheck) | Detects read, write, and delete operations on honeypot files in real-time. |
| **Layer 2: Process & Command Auditing** | `auditd` (Linux) / Sysmon (Windows) | Attributes file access to specific processes and users. Identifies the "who" and "how". |
| **Layer 3: Network Correlation** | Wazuh Log Analysis | Correlates honeypot access with subsequent suspicious network activity (e.g., DNS queries to paste sites, curl/wget outbound). |
| **Layer 4: On-Chain Monitoring** | Block Explorer Watchlists | Detects when an attacker imports stolen keys and interacts with the blockchain (balance queries, transfers). |

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides coverage for several techniques used by attackers during the collection and exfiltration phases of an attack.

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1, 2 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## System Components

### 1. Honeypot Deployer CLI
The core Python application used to generate randomized, realistic-looking wallet artifacts and manage the deployment manifest.

### 2. Artifact Generators
Chain-specific modules that create valid (but empty) wallet structures for:
- Bitcoin (Berkeley DB)
- Ethereum (JSON Keystore & .env)
- Solana (JSON Keypair)
- XRP (JSON)
- Cardano (TextEnvelope)
- BIP-39 Mnemonics (Text/JSON)

### 3. Wazuh Integration
A set of custom decoders and rules for the Wazuh Manager, along with configuration templates for Wazuh Agents. These rules are designed to escalate alerts based on the severity and type of access.

### 4. Active Response
Optional scripts that trigger automated remediation, such as isolating an infected host or taking a forensic snapshot of the system state immediately upon honeypot access.

---

## Security Design

- **Non-Funded Bait:** All generated addresses are for monitoring purposes only. Real funds should never be deposited into honeypot addresses.
- **Encrypted Manifest:** The `manifest.json`, which contains the private keys and metadata for all deployed honeypots, is AES-encrypted at rest to prevent the honeypot system itself from becoming a liability.
- **Zero False Positives:** By placing honeypots in non-standard or hidden directories that no legitimate application should touch, the system achieves an exceptionally low false-positive rate.
