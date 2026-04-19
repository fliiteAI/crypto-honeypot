# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy to catch attackers at various stages of their kill chain, from initial discovery to financial theft.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Monitors honeypot file paths for any read, modify, or delete operations.
- **Goal:** Immediate high-fidelity detection of an attacker or malware interacting with a fake wallet.
- **Attributes:** Uses `realtime="yes"` and `whodata="yes"` for instant alerting and user attribution.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
- **Mechanism:** Tracks which process and user accessed the honeypot files.
- **Goal:** Identify the tool used by the attacker (e.g., `zip`, `curl`, `python`, or a custom infostealer binary).
- **Context:** Differentiates between a manual explorer and an automated script.

### Layer 3: Network Correlation
- **Mechanism:** Correlates file access events with subsequent outbound network activity.
- **Goal:** Detect exfiltration attempts. If a process reads a wallet file and then connects to a remote IP or paste site, the alert severity is escalated.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitoring the public addresses of the generated honeypots on their respective blockchains.
- **Goal:** Detection of the attacker importing the stolen keys and attempting to move funds or query balances, even if they have already left the local environment.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following techniques:

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

## Detection Logic (Wazuh Rules)

Custom rules (IDs 100500+) are designed with a zero-false-positive assumption: **no legitimate user or process should ever access these paths**.

- **Level 12:** Basic file access (FIM).
- **Level 13/14:** Rapid access to multiple honeypots (infostealer pattern).
- **Level 15:** Correlation between file access and on-chain movement.
