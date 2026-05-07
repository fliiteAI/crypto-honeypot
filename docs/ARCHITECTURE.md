# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to catch attackers at various stages of the kill chain, from initial discovery to successful exfiltration and financial theft.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (`syscheck`)
**Objective:** Detect any interaction (read, write, delete) with honeypot wallet files and directories.
- **High Fidelity:** Legitimate users and system processes have no reason to access these hidden/decoy paths.
- **Real-time:** Alerts are generated as soon as the file is touched.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Objective:** Provide context on *who* and *how* the honeypot was accessed.
- **User Attribution:** Identifies the specific user account (UID) responsible for the access.
- **Process Visibility:** Captures the process name, PID, and parent process, allowing us to distinguish between a manual `cat` command and an automated infostealer.

### Layer 3: Network Correlation
**Mechanism:** Wazuh log analysis + Network logs
**Objective:** Detect exfiltration attempts following a honeypot access event.
- **Behavioral Analysis:** Correlates a file access event with subsequent network activity (e.g., `curl` to a paste site, `scp` to an external IP).
- **DNS Monitoring:** Identifies lookups to known exfiltration domains or C2 infrastructure.

### Layer 4: On-Chain Monitoring
**Mechanism:** Block Explorer Watchlists / `honeypot-deployer export-addresses`
**Objective:** Detect if an attacker successfully exfiltrated and attempted to use the stolen keys.
- **The Ultimate Confirmation:** If a transaction occurs on a honeypot address, the compromise is 100% confirmed.
- **Delayed Detection:** Provides visibility even if the initial host-based detection was bypassed or suppressed.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following techniques:

| ID | Technique | Layer | Detection Detail |
|----|-----------|-------|------------------|
| **T1083** | File and Directory Discovery | 1, 2 | Detecting `find`, `ls`, or automated scans of wallet paths. |
| **T1005** | Data from Local System | 1 | Accessing `wallet.dat`, `id.json`, or `.skey` files. |
| **T1555** | Credentials from Password Stores | 1 | Accessing seed phrase backups or recovery files. |
| **T1555.003** | Credentials from Web Browsers | 1 | Accessing browser extension local storage (MetaMask, etc.). |
| **T1560** | Archive Collected Data | 2, 3 | Using `tar` or `zip` on honeypot directories before exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | 3 | Process that touched a wallet then initiates a network connection. |
| **T1048** | Exfiltration Over Alternative Protocol | 3 | Using `curl` or `wget` to move data to a public drop site. |
| **T1657** | Financial Theft | 4 | Detecting balance queries or transfers on the blockchain. |
| **T1070** | Indicator Removal | 1 | Deletion of honeypot files to cover tracks. |

---

## System Components

1. **`honeypot-deployer` CLI:** Python tool for generating unique, randomized artifacts and managing the encrypted manifest.
2. **Wazuh Manager:** Central SIEM that processes logs from agents and triggers alerts based on custom rules.
3. **Wazuh Agent:** Lightweight agent installed on endpoints that performs FIM and collects audit data.
4. **Custom Rules & Decoders:** A specialized set of Wazuh configurations that translate raw filesystem events into high-priority security alerts.
