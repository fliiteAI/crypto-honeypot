# Architecture: Crypto Wallet Honeypot

This document describes the architectural design of the Crypto Wallet Honeypot system, its multi-layered detection strategy, and how it maps to the MITRE ATT&CK framework.

## 4-Layer Detection Strategy

The system utilizes a defense-in-depth approach with four distinct layers of detection to ensure high-fidelity alerts with near-zero false positives.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) monitors specific honeypot artifact paths.
- **Detections:** Any file access (read), modification, or deletion of honeypot wallet files.
- **Fidelity:** Extremely high. Legitimate users or processes should never access these decoy files.

### Layer 2: Process & System Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **Detections:**
    - Identifies the specific process and user accessing honeypot paths.
    - Detects filesystem enumeration (e.g., an attacker searching for `wallet.dat`).
    - Correlates file access with suspicious process behavior.

### Layer 3: Network Correlation
- **Mechanism:** Monitoring network activity following honeypot access.
- **Detections:**
    - Use of exfiltration tools (e.g., `curl`, `scp`, `ftp`) shortly after a honeypot file is read.
    - Connection attempts to known paste sites or C2 infrastructure.
    - Data archiving (e.g., `zip`, `tar`) of directories containing honeypots.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitoring the public blockchain for activity on generated honeypot addresses.
- **Detections:**
    - Transfer of "dust" or any assets into the honeypot address (attacker testing the key).
    - Outbound transactions from the honeypot address (attacker attempting to steal funds).
    - Signature activity on-chain indicating the private key has been imported into a wallet.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot system provides coverage for several techniques used by attackers during the discovery, collection, and exfiltration phases of an attack.

| ID | Technique | Detection Layer | Description |
|----|-----------|-----------------|-------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 | Attacker searching for wallet files and sensitive directories. |
| **T1005** | Data from Local System | Layer 1 | Attacker accessing and collecting wallet artifacts from the endpoint. |
| **T1555** | Credentials from Password Stores | Layer 1 | Attacker targeting cryptocurrency wallet software databases. |
| **T1555.003** | Credentials from Web Browsers | Layer 1 | Attacker targeting browser extension wallet data (e.g., MetaMask). |
| **T1560** | Archive Collected Data | Layer 2, 3 | Attacker compressing honeypot files for exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 | Attacker sending stolen wallet data to their command and control server. |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 | Attacker using common protocols (HTTP/FTP) to exfiltrate wallet data. |
| **T1657** | Financial Theft | Layer 4 | Attacker performing on-chain transactions with stolen private keys. |
| **T1070** | Indicator Removal | Layer 1 | Attacker attempting to delete honeypot files to hide their tracks. |
