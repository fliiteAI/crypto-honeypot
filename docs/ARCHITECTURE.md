# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles and detection strategies used in the Crypto Wallet Honeypot system.

## Detection Strategy: 4-Layer Defense

The system employs a multi-layered detection strategy to identify attackers at various stages of the kill chain.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck)
- **Target:** Direct access (read, modify, delete) to honeypot wallet files.
- **Goal:** Provide high-fidelity, low-latency alerts when an attacker interacts with decoy artifacts.
- **Key Files:** `wallet.dat`, `keystore/`, `id.json`, etc.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon
- **Target:** Process-level visibility into *what* is accessing the honeypot files.
- **Goal:** Distinguish between automated scanners (e.g., `find`, `grep`) and targeted theft tools (infostealers).
- **Correlation:** Detects rapid sequential access to multiple wallet paths, a hallmark of automated infostealers.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh Network/DNS Logs
- **Target:** Exfiltration attempts following honeypot access.
- **Goal:** Correlate honeypot file access with outbound connections to known paste sites (Pastebin), C2 servers, or file upload services (transfer.sh).
- **Behavioral Analysis:** Detects use of archive utilities (zip, tar) shortly after honeypot access, indicating staging for exfiltration.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External Chain Monitor (integrating with Wazuh via API/Logs)
- **Target:** Blockchain activity on the public addresses associated with the honeypot keys.
- **Goal:** Detect when an attacker successfully imports a stolen key and attempts to check balances or transfer funds.
- **Final Confirmation:** Provides definitive proof of successful key theft even if the attacker bypasses host-level monitoring.

---

## MITRE ATT&CK Mapping

The following techniques are covered by the honeypot's detection rules:

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## Component Diagram

1. **Honeypot Deployer (CLI):** Generates randomized artifacts and encrypted manifest.
2. **Wazuh Agent:** Monitors the host filesystem and processes, sending logs to the manager.
3. **Wazuh Manager:** Decodes logs and triggers rules based on the honeypot rule set.
4. **Chain Monitor:** Tracks public addresses on-chain and feeds events back to Wazuh.
