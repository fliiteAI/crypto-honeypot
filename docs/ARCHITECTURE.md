# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense system designed to detect and alert on unauthorized access to cryptocurrency wallet artifacts.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense uses Wazuh's FIM (syscheck) to monitor the honeypot files themselves. Any attempt to read, modify, or delete these files triggers an immediate alert.

### Layer 2: Process Auditing
By integrating with `auditd` (Linux) and `Sysmon` (Windows), the system captures the process and user context behind the file access. This allows us to identify *which* application or user account was used to access the honeypot.

### Layer 3: Network Correlation
Wazuh correlates honeypot file access with subsequent network activity. For example, if a process reads a `wallet.dat` file and then immediately makes an outbound connection to a known paste site or a suspicious IP, the alert severity is escalated.

### Layer 4: On-Chain Monitoring
Even if an attacker successfully exfiltrates the keys and evades host-based detection, their activity can be tracked on the blockchain. By monitoring the public addresses associated with the generated honeypots, we can detect when the stolen keys are imported or used to transact.

---

## MITRE ATT&CK Mapping

The following table maps the honeypot detection capabilities to confirmed MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Component Diagram

1. **Honeypot Deployer (CLI):** Generates artifacts and Wazuh configurations.
2. **Honeypot Artifacts:** Deployed on endpoints (Linux/Windows).
3. **Wazuh Agent:** Monitors artifacts via FIM and Audit/Sysmon.
4. **Wazuh Manager:** Processes events, applies rules, and triggers alerts.
5. **On-Chain Monitor:** Tracks public addresses on block explorers.
