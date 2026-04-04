# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is a multi-layered defensive tool designed to detect and respond to unauthorized access to cryptocurrency wallet artifacts.

## 4-Layer Detection Strategy

The system implements a comprehensive detection strategy that covers the entire lifecycle of a wallet-targeting attack.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
- **Mechanism:** Real-time monitoring of honeypot wallet paths.
- **Goal:** Detect any read, modify, or delete operation on the bait files.
- **Performance:** Zero false positives, as no legitimate process or user should ever access these paths.

### Layer 2: Process & System Auditing (auditd / Sysmon)
- **Mechanism:** Linux `auditd` rules and Windows `Sysmon` events.
- **Goal:** Attribute file access to specific users and processes. Identify "infostealer" patterns like rapid multi-file access or filesystem enumeration.

### Layer 3: Network Correlation
- **Mechanism:** Monitoring for network-capable processes (curl, scp, browser) accessing honeypot files.
- **Goal:** Identify exfiltration attempts immediately following honeypot access.
- **Correlation:** Wazuh rules correlate local file access with subsequent network activity.

### Layer 4: On-Chain Monitoring
- **Mechanism:** Integration with block explorers via the exported honeypot addresses.
- **Goal:** Detect if an attacker successfully imports stolen keys and initiates on-chain transactions.
- **Coverage:** Provides visibility even if the initial host-based detection is bypassed or the host is taken offline.

---

## MITRE ATT&CK Mapping

The system provides coverage for several MITRE ATT&CK techniques used by both automated malware and manual intruders.

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
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

## Component Interaction

1. **`honeypot-deployer` CLI:** Generates unique artifacts and an encrypted manifest.
2. **Wazuh Agent:** Monitors the filesystem using FIM and audit rules.
3. **Wazuh Manager:** Receives logs, decodes them using custom decoders, and triggers alerts based on the custom ruleset.
4. **Active Response:** (Optional) Executes forensic scripts on the agent when a honeypot is tripped.
5. **On-Chain Watchlist:** Monitors the public addresses of the generated honeypots for activity.
