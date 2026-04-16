# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer defense-in-depth strategy designed to detect and alert on unauthorized access to cryptocurrency-related artifacts.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Monitors honeypot file paths for `open`, `read`, `write`, `delete`, and `attribute` changes.
- **Coverage:** Bitcoin `wallet.dat`, Ethereum keystores, Solana `id.json`, and browser extension data.
- **Detection:** Immediate alerts when a process interacts with a honeypot file.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
- **Mechanism:** Hooks into OS-level auditing to identify *which* process and *which* user accessed the files.
- **Key Indicators:**
  - Non-standard processes (e.g., `curl`, `python`, `powershell`, `scp`) accessing wallet directories.
  - Enumeration commands (e.g., `find`, `ls -R`, `dir /s`) hitting multiple honeypot paths in rapid succession.
- **MITRE Mapping:** T1083 (File and Directory Discovery), T1005 (Data from Local System).

### Layer 3: Network Correlation
- **Mechanism:** Correlates file access events with subsequent network activity.
- **Detection:**
  - Outbound connections to common paste sites (Pastebin, Hastebin) or C2 infrastructure immediately following a honeypot trigger.
  - Large data transfers (exfiltration) from the compromised endpoint.
- **MITRE Mapping:** T1041 (Exfiltration Over C2 Channel), T1048 (Exfiltration Over Alternative Protocol).

### Layer 4: On-Chain Monitoring
- **Mechanism:** Monitoring the public addresses of the generated honeypot keys on the blockchain.
- **Detection:**
  - Attacker importing the stolen private key into their own wallet.
  - Attacker querying the balance of the honeypot address on a block explorer.
  - Attacker attempting to transfer (non-existent) funds from the honeypot address.
- **MITRE Mapping:** T1657 (Financial Theft).

---

## MITRE ATT&CK Mapping

| ID | Technique | Layer |
|----|-----------|-------|
| **T1005** | Data from Local System | Layer 1, 2 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Component Diagram

1. **`honeypot-deployer` CLI:** Generates artifacts and encrypted manifest.
2. **Monitored Endpoints:** Host the honeypot artifacts and run Wazuh Agent.
3. **Wazuh Manager:** Collects logs, runs decoders/rules, and triggers alerts.
4. **On-Chain Watcher:** Monitors public addresses for activity (e.g., via Etherscan/Solscan APIs).
