# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware targeting cryptocurrency assets. It employs a multi-layered defense-in-depth strategy, ranging from local file monitoring to on-chain transaction tracking.

## Detection Philosophy: Zero False Positives

The system is predicated on a single, powerful rule: **Legitimate users and authorized processes have no reason to access, read, or modify the honeypot files.**

Because the artifacts are placed in locations typically hidden from casual users but actively scanned by automated infostealers (e.g., `~/.bitcoin/wallet.dat` or browser extension storage), any interaction with these files is a high-confidence indicator of malicious activity.

## The 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
Wazuh's `syscheck` module monitors the honeypot artifacts in real-time.
- **Read Access:** Detected via `auditd` (Linux) or Sysmon (Windows) integration within Wazuh FIM.
- **Modification/Deletion:** Triggers immediate high-priority alerts.
- **Goal:** Provide the earliest possible warning that a system has been compromised and is being searched for credentials.

### Layer 2: Process & Command Auditing
Beyond just knowing *that* a file was accessed, we need to know *what* accessed it.
- **User Attribution:** Identifies exactly which user account was used to access the honeypot.
- **Process Identification:** Logs the parent process, command-line arguments, and executable path (e.g., `curl`, `python`, or a known infostealer binary).
- **Behavioral Analysis:** Detects patterns such as rapid, sequential access to multiple different wallet types, a hallmark of automated "stealer" malware.

### Layer 3: Network Correlation
Most attackers don't just steal keys; they exfiltrate them.
- **Exfiltration Detection:** Correlates honeypot file access with subsequent network activity to known "paste" sites (Pastebin, etc.), C2 servers, or unusual outbound connections (curl, scp).
- **DNS Monitoring:** Detects resolution of domains associated with malware exfiltration immediately following a honeypot trigger.

### Layer 4: On-Chain Monitoring
The final layer of detection occurs outside the compromised host.
- **Bait Addresses:** Every generated honeypot contains a unique, non-funded public address.
- **Watchlists:** These addresses are added to block explorer watchlists or monitored via custom scripts.
- **Attacker Evaluation:** When an attacker imports the stolen key and queries the balance or attempts a transfer, an alert is triggered on-chain.
- **Confirmed Compromise:** Correlating a Layer 1 local trigger with a Layer 4 on-chain trigger provides 100% confirmation of a successful theft and key compromise.

---

## MITRE ATT&CK Mapping

The system provides coverage for several key techniques used by attackers during the discovery, credential access, and exfiltration phases.

| Technique ID | Name | Detection Layer |
|--------------|------|-----------------|
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

## Component Overview

- **`honeypot-deployer` CLI:** A Python application that generates realistic, randomized artifacts and manages the encrypted manifest of private keys and addresses.
- **Wazuh Agent:** Installed on endpoints to perform FIM and log collection.
- **Wazuh Manager:** Processes incoming logs, applies custom decoders and rules, and triggers alerts/active responses.
- **Chain Monitor (External):** A service (or manual process) that watches the public blockchain for activity on the generated honeypot addresses.
