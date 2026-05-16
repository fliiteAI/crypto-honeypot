# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to catch attackers at various stages of the kill chain, from initial discovery to successful exfiltration and financial theft.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** Monitors the honeypot wallet files and directories for any read, modification, or deletion events. This is the first line of defense and provides high-fidelity alerts.
**Key Features:**
- `realtime="yes"` for immediate alerting.
- `whodata="yes"` for user attribution (requires `auditd` on Linux).
- Cross-platform support (Linux & Windows).

### Layer 2: Process Auditing & Filesystem Enumeration
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Detects the specific processes accessing honeypot paths. It can identify automated infostealers by looking for rapid multi-file access patterns across multiple wallet types.
**Key Features:**
- Detects directory traversal and enumeration.
- Correlates file access with process metadata (parent process, command line).

### Layer 3: Network Correlation
**Mechanism:** Wazuh log analysis
**Description:** Correlates honeypot file access with subsequent network activity. For example, if a process reads a wallet file and then immediately uses `curl` or `scp`, it triggers a high-severity alert.
**Detection Patterns:**
- Outbound connections to known paste sites or exfiltration endpoints.
- Use of archiving utilities (`tar`, `zip`) immediately following honeypot access.

### Layer 4: On-Chain Monitoring
**Mechanism:** Block Explorer Watchlists / On-Chain APIs
**Description:** Tracks the generated honeypot public addresses on various blockchains. If an attacker imports a stolen private key and interacts with the chain (even just a balance query), an alert is triggered.
**Key Features:**
- 100% true positive rate (no legitimate user has the keys).
- Detection even if the attacker succeeds in exfiltrating data without being caught by endpoint logs.

---

## MITRE ATT&CK Mapping

The system's detection capabilities map to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer | Description |
|----|-----------|-----------------|-------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 | Monitoring for access to common wallet locations. |
| **T1005** | Data from Local System | Layer 1 | Direct access to sensitive wallet files. |
| **T1555** | Credentials from Password Stores | Layer 1 | Wallet files are a primary source of credentials. |
| **T1555.003** | Credentials from Web Browsers | Layer 1 | Monitoring browser extension storage directories. |
| **T1560** | Archive Collected Data | Layer 2, 3 | Detecting the use of tools like `zip` or `tar` on honeypot data. |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 | Correlating file access with C2 network traffic. |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 | Detecting exfiltration via `curl`, `scp`, etc. |
| **T1657** | Financial Theft | Layer 4 | On-chain activity using honeypot private keys. |
| **T1070** | Indicator Removal | Layer 1 | Detecting deletion of honeypot files as an attempt to hide tracks. |

---

## Detection Logic Flow

1. **Generation:** `honeypot-deployer` creates randomized wallet artifacts and a secure manifest.
2. **Deployment:** Artifacts are placed in standard locations where attackers/malware expect them.
3. **Trigger:** An unauthorized entity accesses a file.
4. **Alerting:** Wazuh Agent sends event -> Wazuh Manager matches rule -> Alert generated.
5. **Response:** (Optional) Active response script triggers a forensic snapshot of the system.
6. **Correlation:** Security team checks block explorer watchlists for on-chain movement.
