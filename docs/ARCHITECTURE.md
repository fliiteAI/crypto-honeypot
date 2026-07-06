# Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and info-stealer malware targeting cryptocurrency assets.

## 4-Layer Detection Strategy

The system utilizes a multi-layered approach to ensure that even if an attacker bypasses one detection mechanism, others will catch them.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (Syscheck).
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Goal:** Provide immediate alerts the moment a honeypot file is touched.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows Sysmon.
- **What It Detects:** The specific process name, user, and command-line arguments used to access the honeypot files.
- **Goal:** Identify the tool (e.g., `cat`, `curl`, `metastealer.exe`) and the user account responsible for the access.

### Layer 3: Network Exfiltration Correlation
- **Mechanism:** Wazuh log correlation.
- **What It Detects:** Network activity (DNS queries to paste sites, outbound connections via `curl` or `scp`) occurring immediately after honeypot file access.
- **Goal:** Confirm that data exfiltration is actually occurring, increasing the alert severity.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists (or a dedicated monitor service).
- **What It Detects:** Activity on the blockchain (balance queries, transfers) involving the generated honeypot addresses.
- **Goal:** Detect attackers who have successfully stolen keys and are attempting to use them on-chain, even after they have left the local environment.

## MITRE ATT&CK Mapping

The system detects the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## The "Zero False Positive" Philosophy

A core design principle of this system is that **no legitimate user or process has any reason to access these honeypot files.**

- **Randomized Content:** Artifacts are generated with randomized keys and look like real wallets, but they are not used for any legitimate purpose.
- **Restricted Access:** By placing these files in realistic but non-operational paths, any access is by definition suspicious.
- **High Fidelity:** Because the base assumption is that access = attacker, alerts can be configured with high severity (Level 12+) and used to trigger automated remediation (Active Response) without fear of disrupting legitimate work.

## System Components

1. **`honeypot-deployer` CLI:** A Python-based tool for generating randomized artifacts and managing the deployment manifest.
2. **Honeypot Artifacts:** Realistic files (BTC `wallet.dat`, ETH keystores, etc.) that act as bait.
3. **Wazuh Manager:** The central SIEM that receives events, applies rules, and generates alerts.
4. **Wazuh Agents:** Installed on endpoints to monitor files and report activity.
5. **Auditd/Sysmon:** System-level auditing tools that provide process context to Wazuh.
