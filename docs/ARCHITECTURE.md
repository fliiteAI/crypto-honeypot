# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers targeting cryptocurrency assets. It employs a multi-layered detection strategy that spans from local host activity to global blockchain monitoring.

## 4-Layer Detection Strategy

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1: FIM** | Wazuh File Integrity Monitoring | Any read, modification, or deletion of honeypot wallet files and browser extension directories. |
| **Layer 2: Process Auditing** | Linux `auditd` / Windows Sysmon | Identifies the specific process and user accessing the honeypot files, providing critical forensic context. |
| **Layer 3: Network Correlation** | Wazuh Log Analysis | Correlates honeypot file access with subsequent network activity (e.g., `curl` to paste sites, `scp` transfers). |
| **Layer 4: On-Chain Monitoring** | Blockchain Watchlists | Detects when an attacker imports a stolen private key and interacts with the blockchain (balance queries, transfers). |

## Detection Workflow

1.  **Deployment:** Realistic but non-funded wallet artifacts are deployed across monitored endpoints.
2.  **Trigger:** An attacker or malware (e.g., an infostealer) accesses a honeypot file.
3.  **Local Alert:** Wazuh FIM and process auditing detect the access and generate a high-severity alert (Level 12+).
4.  **Forensic Snapshot:** An Active Response script automatically captures process trees and network connections on the affected host.
5.  **Global Monitoring:** If the attacker uses the stolen keys, blockchain watchlists trigger external alerts, confirming the compromise and potential exfiltration.

## MITRE ATT&CK Mapping

The system provides coverage for several key techniques used by attackers during credential access and exfiltration:

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

## Components

-   **`honeypot-deployer` CLI:** A Python-based tool for generating randomized, realistic artifacts and managing the encrypted manifest.
-   **Wazuh SIEM:** The central monitoring and alerting engine, utilizing custom decoders and rules (IDs 100500-100599).
-   **Host Agents:** Monitored endpoints running Wazuh Agent with `auditd` (Linux) or Sysmon (Windows) for deep visibility.
