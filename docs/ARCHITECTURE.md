# Architecture Overview: Crypto Wallet Honeypot

This document describes the design philosophy, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## Design Philosophy

The system is built on a **zero false positive** principle. Legitimate users and automated system processes have no reason to access the generated honeypot files. Therefore, any interaction with these files is considered high-fidelity evidence of unauthorized activity.

The system is designed for SMB (Small and Medium-sized Business) environments, specifically optimized to run on lightweight infrastructure like Raspberry Pi-based Wazuh Managers.

## 4-Layer Detection Strategy

The honeypot implements a multi-layered approach to detect and correlate attacker activity from initial discovery to final exfiltration and on-chain use.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **Description:** Detects any read, modification, or deletion of honeypot files in real-time.
- **Detections:** Access to `wallet.dat`, Ethereum keystores, Solana `id.json`, and browser extension data.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **Description:** Provides process-level visibility into *who* and *what* accessed the honeypot files.
- **Detections:** Identifies the specific binary (e.g., `curl`, `python`, `scp`) and the user account responsible for the access.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis
- **Description:** Correlates honeypot file access with subsequent network activity.
- **Detections:** Detects processes that access a honeypot and then initiate outbound connections to common exfiltration points (paste sites, file upload services) or C2 infrastructure.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Blockchain Watchlists (via `chain-monitor`)
- **Description:** Monitors the public addresses associated with the honeypot's private keys.
- **Detections:** Alerts when an attacker imports a stolen key and queries the balance or attempts an outbound transfer on the live blockchain.

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## System Components

1. **`honeypot-deployer` CLI:** Generates realistic artifacts and manages the encrypted manifest.
2. **Wazuh Agent:** Monitors the filesystem and process activity on target endpoints.
3. **Wazuh Manager:** Processes events from agents and triggers alerts based on custom rules.
4. **Chain Monitor:** (Optional) External service that monitors blockchain addresses for activity.
