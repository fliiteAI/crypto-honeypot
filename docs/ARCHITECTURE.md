# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection strategy, and security principles of the Crypto Wallet Honeypot system.

## Detection Strategy: 4-Layer Defense

The system employs a multi-layered detection strategy to catch attackers at various stages of the kill chain, from initial discovery to final exfiltration and use of stolen assets.

### Layer 1: File Integrity Monitoring (FIM)
The primary detection mechanism. Wazuh's FIM (Syscheck) is configured to monitor honeypot wallet files and directories. Any read, modification, or deletion event triggers an immediate high-severity alert.
- **Mechanism:** Wazuh `whodata` monitoring (via `auditd` on Linux) and FIM events.
- **Sensitivity:** Maximum. Every access is considered unauthorized.

### Layer 2: Process & Command Auditing
Provides context by identifying *which* process and user accessed the honeypot. This layer distinguishes between manual exploration (e.g., `ls`, `cat`) and automated malware (e.g., info-stealers).
- **Mechanism:** Linux `auditd` rules and Windows Sysmon.
- **Alerting:** Detects rapid sequential access to multiple honeyfiles, a hallmark of automated scanners.

### Layer 3: Network Correlation
Correlates honeypot file access with network activity. If a process accesses a honeyfile and subsequently connects to a paste site, C2 server, or uses exfiltration tools (e.g., `curl`, `scp`), the alert severity is escalated.
- **Mechanism:** Wazuh integration with network logs and process auditing.
- **Scope:** Detects exfiltration staging and outbound data transfer.

### Layer 4: On-Chain Monitoring
The final safety net. Even if an attacker successfully exfiltrates a private key without triggering local alerts (e.g., via a zero-day or by bypassing local monitoring), their activity will be detected as soon as they use the key on-chain.
- **Mechanism:** Automated monitoring of honeypot public addresses using block explorer APIs and watchlists.
- **Alerting:** High-fidelity alerts for balance queries, token approvals, and outbound transfers.

---

## MITRE ATT&CK Mapping

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

## Zero False Positive Design

The core philosophy of this system is **zero false positives**. This is achieved through strict isolation:
1. **No Legitimate Use:** There is no scenario where a legitimate user or authorized system process should access the honeypot files.
2. **Distinctive Paths:** Honeyfiles are placed in standard but distinct paths (e.g., `~/.bitcoin/wallet.dat`) that are highly attractive to attackers but easily ignored by normal operations.
3. **High Fidelity:** Because any access is by definition unauthorized, alert fatigue is eliminated, allowing security teams to respond with high confidence.

---

## Data Flow

1. **Generation:** `honeypot-deployer` generates randomized keys and realistic artifacts.
2. **Deployment:** Artifacts are placed on target endpoints; public addresses are exported for on-chain monitoring.
3. **Monitoring:** Wazuh agents monitor local file and process activity; external monitors track chain activity.
4. **Alerting:** Events are sent to the Wazuh Manager, where custom rules correlate data and trigger alerts/active responses.
