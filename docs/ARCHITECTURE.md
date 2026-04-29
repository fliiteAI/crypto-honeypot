# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense system designed to detect and alert on unauthorized access to cryptocurrency-related artifacts. It integrates deeply with Wazuh SIEM to provide high-fidelity alerts with zero false positives.

## Detection Strategy

The system employs a 4-layer detection strategy to catch attackers at various stages of their operation.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (`syscheck`).
- **Description:** Monitors honeypot wallet files for any read, modification, or deletion events.
- **Goal:** Real-time detection of local file access.
- **MITRE ATT&CK Mapping:** T1005 (Data from Local System), T1555 (Credentials from Password Stores), T1555.003 (Credentials from Web Browsers).

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **Description:** Captures the specific process and user responsible for accessing a honeypot file. It also detects rapid sequential access to multiple wallet paths, a classic signature of infostealer malware.
- **Goal:** Provide attribution and context for file access events.
- **MITRE ATT&CK Mapping:** T1083 (File and Directory Discovery), T1070 (Indicator Removal).

### Layer 3: Network Correlation
- **Mechanism:** DNS logs and process-to-network correlation.
- **Description:** Identifies when a network-capable process (e.g., `curl`, `powershell`) touches a honeypot file or when a system resolves a known exfiltration domain (e.g., Pastebin, Telegram API) shortly after honeypot access.
- **Goal:** Detect exfiltration attempts before the data leaves the environment.
- **MITRE ATT&CK Mapping:** T1041 (Exfiltration Over C2 Channel), T1048 (Exfiltration Over Alternative Protocol), T1560 (Archive Collected Data).

### Layer 4: On-Chain Monitoring
- **Mechanism:** Block explorer watchlists and custom chain monitors.
- **Description:** Tracks the generated honeypot public addresses on their respective blockchains. Any activity (balance query, transfer) on these addresses indicates the attacker has successfully exported and is using the stolen keys.
- **Goal:** Confirm successful compromise and trace attacker movement on-chain.
- **MITRE ATT&CK Mapping:** T1657 (Financial Theft).

---

## MITRE ATT&CK Mapping Summary

| Technique | Name | Layer |
|-----------|------|-------|
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1070** | Indicator Removal | Layer 2 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## System Components

1. **Honeypot Deployer (CLI):** Python-based tool for generating randomized, realistic artifacts and managing the deployment manifest.
2. **Wazuh Manager:** Central SIEM that receives events, decodes them using custom decoders, and fires alerts based on specialized rules.
3. **Wazuh Agent:** Lightweight agent installed on endpoints that performs FIM and collects audit/Sysmon logs.
4. **Chain Monitor:** External process (or block explorer watchlist) that monitors public addresses for on-chain activity.
