# Architecture Overview

The Crypto Wallet Honeypot system is a multi-layered defensive security solution designed to detect and respond to attackers targeting cryptocurrency assets. It follows a "defense-in-depth" approach with four distinct detection layers.

## Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The primary detection layer uses Wazuh's FIM (syscheck) to monitor decoy files.
- **Mechanism:** Real-time monitoring of honeypot directories.
- **Events:** Triggers on `added`, `modified`, or `read` events (via `whodata`).
- **Fidelity:** Near-zero false positives, as legitimate users or system processes have no reason to access these hidden/decoy paths.

### Layer 2: Process Auditing & User Attribution
Provides context on *who* and *how* the honeypot was accessed.
- **Linux:** Uses `auditd` rules (`-p r`) to capture the exact command line and parent process that accessed a honeyfile.
- **Windows:** Uses Sysmon (Event ID 1) to track process creation and filesystem access.
- **Benefit:** Distinguishes between a manual attacker (`cat wallet.dat`) and automated malware/infostealers.

### Layer 3: Network & Behavioral Correlation
Detects the "Next Step" in the attack lifecycle: Exfiltration.
- **Mechanism:** Correlates honeypot file access with subsequent network activity from the same PID or User ID.
- **Indicators:** Usage of `curl`, `wget`, `scp`, or connections to known paste sites/C2 IP addresses shortly after accessing a honeypot.

### Layer 4: On-Chain Monitoring
The final layer of detection that works even if the attacker successfully exfiltrates the data.
- **Mechanism:** Monitoring the public addresses associated with the honeypot private keys using block explorer watchlists (Etherscan, Solscan, etc.).
- **Detection:** Triggers when the attacker imports the private key into a wallet and performs a balance query or attempted transfer.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following techniques:

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

## Data Flow

1. **Honeypot-Deployer CLI:** Generates randomized artifacts and encrypted manifest.
2. **Endpoint Agent:** Monitors paths and sends events to Wazuh Manager.
3. **Wazuh Manager:** Processes events through custom decoders and rules.
4. **Active Response:** (Optional) Triggers forensic snapshots or account lockouts upon high-severity alerts.
5. **Security Dashboard:** Visualizes alerts and correlates multi-layer detections.
