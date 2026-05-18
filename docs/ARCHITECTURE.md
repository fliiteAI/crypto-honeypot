# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and track attackers targeting cryptocurrency credentials. It integrates with Wazuh SIEM to provide high-fidelity alerts through four distinct detection layers.

## 4-Layer Detection Strategy

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The foundation of the system is Wazuh's File Integrity Monitoring. By placing realistic wallet artifacts (like `wallet.dat`, `keystore` files, and `.skey` files) in standard locations, we create a high-fidelity trigger.
- **Mechanism:** Real-time monitoring for `added`, `modified`, or `read` events on honeypot paths.
- **What It Detects:** Any direct interaction with the honeyfiles by infostealers or manual intruders.

### Layer 2: Process Auditing (auditd / Sysmon)
To distinguish between casual filesystem enumeration and targeted theft, we use OS-level auditing.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **What It Detects:** Which process accessed the file, what user was involved, and what actions were taken immediately before and after the access (e.g., zipping files, executing `curl`).

### Layer 3: Network Correlation
Most attackers will attempt to exfiltrate the stolen data.
- **Mechanism:** Correlating honeypot file access events with outbound network connections.
- **What It Detects:** Exfiltration attempts to known paste sites, C2 servers, or via common tools like `scp` and `ftp`.

### Layer 4: On-Chain Monitoring
The final layer tracks the movement of "stolen" credentials on the blockchain itself.
- **Mechanism:** Monitoring the public addresses of the generated honeypots using block explorer watchlists or custom scripts.
- **What It Detects:** An attacker importing the stolen private keys into a wallet and checking balances or attempting transactions.

## MITRE ATT&CK Mapping

The system provides coverage for the following techniques:

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

## System Components

- **Honeypot Deployer CLI:** A Python-based tool for generating randomized, realistic artifacts and managing deployment manifests.
- **Wazuh Manager:** Centralized SIEM that receives events, applies custom decoders and rules, and triggers alerts.
- **Wazuh Agent:** Installed on endpoints to perform FIM and log collection.
- **Auditd/Sysmon:** OS-native tools for deep process visibility.
