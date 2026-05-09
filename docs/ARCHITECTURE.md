# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design and detection strategy of the Crypto Wallet Honeypot system.

## Detection Strategy: 4-Layer Defense

The system employs a multi-layered detection approach to ensure high-fidelity alerts with zero false positives. Since legitimate users never access honeypot files, any activity involving these artifacts is considered malicious.

### Layer 1: Wazuh File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh `syscheck` module.
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Fidelity:** extremely high. Legitimate applications do not look for these specific files in these specific paths unless they are performing discovery or theft.

### Layer 2: Process Auditing (auditd / Sysmon)
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **What It Detects:**
    - Which process accessed the honeypot file.
    - Process-level filesystem enumeration.
    - User attribution (who performed the action).
- **Benefit:** Provides the "who" and "how" behind the file access, distinguishing between a manual intruder and an automated infostealer.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis and network flow monitoring.
- **What It Detects:**
    - Exfiltration attempts (e.g., `curl`, `scp`, or posts to paste sites) occurring shortly after a honeypot access.
    - Communication with known malicious C2 (Command & Control) infrastructure.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Watchlists on block explorers (Etherscan, Solscan, Blockchain.com).
- **What It Detects:**
    - The attacker importing the stolen private keys into a wallet.
    - Balance checks or transaction attempts on the non-funded honeypot addresses.
- **Benefit:** Provides definitive proof of successful exfiltration and attacker intent, even if the initial access was missed by host-based controls.

---

## MITRE ATT&CK Mapping

The system is designed to detect techniques used during the Discovery, Collection, and Exfiltration stages of an attack.

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
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

1. **`honeypot-deployer` CLI:** Generates artifacts and creates an encrypted `manifest.json`.
2. **Wazuh Agent:** Monitors the deployed artifacts using FIM and audit rules.
3. **Wazuh Manager:** Processes events from agents, triggers alerts based on custom rules, and optionally executes active response scripts.
4. **Active Response:** Can trigger automated remediation, such as isolating the host or taking a forensic snapshot.
5. **On-Chain Watcher:** (External) Alerts security teams when activity is detected on the blockchain for the honeypot addresses.
