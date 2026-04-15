# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## 4-Layer Detection Strategy

The system utilizes a multi-layered defense-in-depth approach to ensure high-fidelity detection with zero false positives.

### Layer 1: Wazuh File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh `syscheck` module.
- **Detection:** Any read, modification, or deletion of honeypot wallet files and directories.
- **Configuration:** Uses `whodata="yes"`, `realtime="yes"`, and `report_changes="yes"` to capture maximum context.
- **High Fidelity:** Since these files are decoys and are not used by legitimate applications or users, any access is inherently suspicious.

### Layer 2: OS-Level Auditing (auditd / Sysmon)
- **Mechanism:** `auditd` on Linux, `Sysmon` on Windows.
- **Detection:** Process-level attribution for file access. It identifies *which* process or user accessed the honeypot.
- **Context:** Helps distinguish between a manual attacker (using `cat`, `type`, `ls`) and automated malware (infostealers scanning standard paths).

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis correlating FIM events with network activity.
- **Detection:** Outbound network connections (e.g., `curl`, `scp`, `powershell` web requests) occurring immediately after a honeypot file access.
- **Goal:** Identify exfiltration attempts and the destination of stolen "data."

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitoring of the public blockchain addresses associated with the honeypot keys.
- **Detection:** Transactions, balance queries, or contract interactions involving the honeypot addresses.
- **Result:** Provides definitive proof of successful exfiltration and indicates the attacker's intent to monetize the stolen credentials.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot system provides coverage for the following techniques:

| ID | Name | Phase | Detection Layer |
|----|------|-------|-----------------|
| **T1005** | Data from Local System | Collection | Layer 1, 2 |
| **T1070** | Indicator Removal | Defense Evasion | Layer 1 |
| **T1555** | Credentials from Password Stores | Credential Access | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Credential Access | Layer 1 |
| **T1083** | File and Directory Discovery | Discovery | Layer 1, 2 |
| **T1041** | Exfiltration Over C2 Channel | Exfiltration | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Exfiltration | Layer 3 |
| **T1560** | Archive Collected Data | Collection | Layer 2, 3 |
| **T1657** | Financial Theft | Impact | Layer 4 |

---

## System Components

1. **Honeypot Deployer (CLI):** Generates randomized, realistic wallet artifacts and encrypted manifests.
2. **Wazuh Agent:** Monitors the local filesystem and processes on target endpoints.
3. **Wazuh Manager:** Centralizes logs, applies custom decoders and rules, and triggers alerts.
4. **Wazuh Dashboard:** Provides visualization of security events and honeypot hits.
5. **On-Chain Watcher (External):** Tracks the generated addresses on-chain (e.g., via Etherscan/Solscan watchlists).
