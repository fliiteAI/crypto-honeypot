# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and alert on unauthorized access to cryptocurrency-related artifacts. It integrates deeply with Wazuh SIEM to provide high-fidelity alerts with zero false positives.

## Detection Strategy

Our strategy relies on four distinct layers of detection, ensuring that an attacker is caught regardless of their methods.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh Syscheck.
- **Goal:** Detect any read, modification, or deletion of honeypot wallet files.
- **Fidelity:** extremely high. Legitimate users have no reason to access these hidden, decoy paths.

### Layer 2: Process & User Auditing
- **Mechanism:** `auditd` (Linux) and Sysmon (Windows).
- **Goal:** Identify the specific process and user responsible for the access.
- **Benefit:** Allows security teams to distinguish between automated malware (e.g., infostealers) and manual exploration by an intruder.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log correlation and network monitoring.
- **Goal:** Correlate honeypot file access with subsequent network activity (e.g., DNS queries to paste sites, HTTP POST requests to known C2 servers).
- **Context:** Provides a complete picture of the exfiltration attempt.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Blockchain watchlists.
- **Goal:** Detect when an attacker imports the stolen honeypot private keys into a real wallet and attempts to check balances or move funds.
- **Fidelity:** Absolute. Once a key is used on-chain, it confirms the data was successfully exfiltrated and is being actively used.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several techniques used by attackers during the discovery, collection, and exfiltration phases.

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

## System Components

1. **`honeypot-deployer` CLI:** The core Python application used to generate randomized, realistic artifacts and manage the encrypted manifest.
2. **Honeypot Artifacts:** Chain-specific files (BTC `wallet.dat`, ETH Keystore, etc.) and browser extension decoys.
3. **Encrypted Manifest:** A secure JSON file that stores the mapping between honeypot files, their corresponding public addresses, and private keys.
4. **Wazuh Decoders & Rules:** Custom XML configurations for the Wazuh Manager to parse and alert on honeypot-specific events.
5. **Wazuh Agent Configurations:** Endpoint-specific configurations for FIM and audit rules.
