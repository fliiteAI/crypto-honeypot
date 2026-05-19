# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense system designed to detect, attribute, and monitor attackers targeting cryptocurrency credentials. It integrates closely with Wazuh SIEM to provide real-time alerts.

## 4-Layer Detection Strategy

The system employs four distinct layers of detection to ensure high-fidelity alerts even if an attacker manages to bypass one or more layers.

### Layer 1: File Integrity Monitoring (FIM)
The primary detection mechanism. Wazuh's `syscheck` module monitors honeypot artifact paths for any access (read, modify, delete).
- **Mechanism:** Wazuh FIM (`realtime="yes"`, `whodata="yes"`).
- **Goal:** Immediate notification of any interaction with honeypot files.
- **Alert Level:** 12-14 (High Severity).

### Layer 2: Process Auditing
Complements FIM by providing context on *how* the files were accessed and *what* happened next.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Goal:** Identify the specific process (e.g., `curl`, `tar`, `python`) used to access the honeypot. Detects infostealer patterns (rapid sequential access to multiple wallet paths).
- **Alert Level:** 10-14.

### Layer 3: Network Correlation
Monitors for exfiltration attempts or recon activity following a honeypot access event.
- **Mechanism:** DNS query logging and process network activity monitoring.
- **Goal:** Detect connections to known paste sites (`pastebin.com`), file sharing services (`transfer.sh`), or C2 infrastructure shortly after a wallet file is touched.

### Layer 4: On-Chain Monitoring
The final layer of detection that tracks the stolen credentials once they leave the endpoint.
- **Mechanism:** `honeypot-deployer export-addresses` + Block explorer watchlists (Etherscan, Solscan, etc.).
- **Goal:** Detect when an attacker imports the private key into a wallet and performs on-chain actions like balance queries or transfers.

---

## MITRE ATT&CK Mapping

The honeypot's detections are mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Component Overview

### `honeypot-deployer` CLI
The core Python application used to:
1. **Generate** randomized, realistic wallet artifacts and encrypted manifests.
2. **Export** public addresses for on-chain monitoring.
3. **Generate** localized Wazuh FIM configurations for deployment.
4. **Health-check** deployed artifacts.

### Wazuh Manager
Central SIEM that receives events from agents. It contains:
- **Custom Decoders:** To parse honeypot-specific audit and chain-monitor logs.
- **Custom Rules:** 15+ rules designed to detect various stages of a crypto-theft attack.
- **Active Response:** Scripts that can trigger automated remediation (e.g., locking a user account) upon a honeypot hit.

### Wazuh Agents
Deployed on endpoints to monitor files and processes. They utilize `auditd` (Linux) and `Sysmon` (Windows) for high-fidelity telemetry.
