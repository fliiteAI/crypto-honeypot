# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is built on a "zero false positive" design philosophy. Since legitimate users and authorized processes have no reason to access these decoy wallet files, any interaction is treated as a high-fidelity indicator of compromise.

## 4-Layer Detection Strategy

The system employs a multi-layered detection approach to track an attacker's lifecycle from initial discovery to exfiltration and final monetization.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** Detects any read, modification, or deletion of honeypot files. On Linux, this is enhanced with `auditd` to provide "whodata" (user and process attribution).
**Alert Range:** 100500-100509

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Monitors the execution of processes that interact with honeypot paths. This layer identifies *how* the files were accessed (e.g., via `grep`, `cat`, or a custom infostealer binary) and detects rapid filesystem enumeration patterns.
**Alert Range:** 100510-100519

### Layer 3: Network Correlation
**Mechanism:** Wazuh Analysis Engine
**Description:** Correlates honeypot file access with subsequent network activity. For example, if a process reads a wallet file and then immediately initiates an outbound connection to a known paste site or C2 IP, the alert level is escalated.
**Alert Range:** 100520-100529

### Layer 4: On-Chain Monitoring
**Mechanism:** Block Explorer Watchlists / On-Chain Scripts
**Description:** Tracks the generated honeypot public addresses on their respective blockchains (BTC, ETH, SOL, etc.). If funds are moved from or to these addresses, it confirms a successful compromise and exfiltration.
**Alert Range:** 100530-100539

---

## MITRE ATT&CK® Mapping

The detections provided by this system map to the following MITRE ATT&CK techniques:

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

## Design Principles

1. **Zero False Positives:** Honeypot files are placed in paths that should never be accessed by normal user activity.
2. **Realism:** Artifacts (like `wallet.dat` or Ethereum keystores) are generated with valid structures and randomized content to appear authentic to both automated tools and manual investigators.
3. **Low Overhead:** The system leverages native OS auditing tools (`auditd`, Sysmon) and a lightweight Wazuh agent.
4. **Actionable Intelligence:** Alerts provide context, including the user, process, and parent process responsible for the access.
