# Architecture Overview: Crypto Wallet Honeypot

This document describes the 4-layer detection strategy and the system architecture of the Crypto Wallet Honeypot.

## Detection Strategy

The system employs a multi-layered approach to detect attackers at different stages of their lifecycle, from initial discovery to exfiltration and financial realization.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) monitors honeypot wallet files for any access, modification, or deletion.
- **Goal:** Detect the moment an attacker or malware interacts with a decoy wallet file.
- **Fidelity:** extremely high. Legitimate users have no reason to touch these files.

### Layer 2: Process Auditing
- **Mechanism:** `auditd` (Linux) and Sysmon (Windows) track which processes are accessing the honeypot files.
- **Goal:** Identify the tool used by the attacker (e.g., `python`, `curl`, `powershell`, or a known infostealer binary) and provide user attribution.
- **Alerts:** Triggered when a non-whitelisted process accesses a monitored path.

### Layer 3: Network Correlation
- **Mechanism:** Correlating FIM/Audit events with outbound network connections.
- **Goal:** Detect exfiltration attempts. For example, if a process reads `wallet.dat` and immediately makes a POST request to a paste site or a known C2 IP.
- **Context:** Provides evidence of successful data theft.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitoring the public addresses of the honeypots on their respective blockchains.
- **Goal:** Detect when an attacker imports the stolen private keys into a real wallet and performs on-chain actions (checking balance or attempting a transfer).
- **Finality:** Provides 100% confirmation of compromise, even if the attacker managed to bypass endpoint detection.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides coverage for the following techniques:

| ID | Technique | Layer | Description |
|----|-----------|-------|-------------|
| **T1083** | File and Directory Discovery | 1, 2 | Attacker searching for wallet files. |
| **T1005** | Data from Local System | 1 | Attacker reading wallet artifacts. |
| **T1555** | Credentials from Password Stores | 1 | Accessing stored crypto credentials. |
| **T1555.003** | Credentials from Web Browsers | 1 | Accessing browser extension wallet data. |
| **T1560** | Archive Collected Data | 2 | Attacker zipping up wallet folders. |
| **T1041** | Exfiltration Over C2 Channel | 3 | Sending stolen keys to C2. |
| **T1048** | Exfiltration Over Alternative Protocol | 3 | Uploading keys to public file sharing sites. |
| **T1657** | Financial Theft | 4 | Attacker attempting to move funds (on-chain). |
| **T1070** | Indicator Removal | 1 | Attacker deleting the honeypot after stealing it. |

---

## Component Diagram

1. **Honeypot Deployer (CLI):** Generates artifacts and manifest.
2. **Endpoints:** Host the honeypot artifacts and run Wazuh Agents.
3. **Wazuh Manager:** Receives events, applies decoders/rules, and triggers alerts.
4. **Blockchain Watcher:** (External) Monitors on-chain activity for honeypot addresses.
