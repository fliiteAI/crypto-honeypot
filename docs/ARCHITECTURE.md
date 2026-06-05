# Architecture Overview: Crypto Wallet Honeypot

This document describes the design philosophy and detection strategy of the Crypto Wallet Honeypot system.

## Design Philosophy: "Zero False Positives"

The core principle of this honeypot is that **legitimate users and processes have no reason to access these files.**

By placing realistic-looking wallet artifacts in standard (but unused) locations, any interaction with them is inherently suspicious. This allows for high-severity alerts (Level 12-15 in Wazuh) with a near-zero false positive rate, enabling automated remediation like account lockout or forensic snapshots.

---

## 4-Layer Detection Strategy

The system employs a multi-layered approach to detect and correlate attacker activity from the initial discovery to final exfiltration and on-chain use.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (`syscheck`).
- **Detection:** Triggers on any `read`, `modify`, or `delete` operation on a honeypot file.
- **Goal:** Immediate notification of file-level interaction.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` / Windows Sysmon.
- **Detection:** Captures *which* process accessed the file, the parent process, and the user context.
- **Goal:** Attribution and behavior analysis (e.g., distinguishing a manual `cat` command from an automated infostealer scan).

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log analysis & DNS monitoring.
- **Detection:** Correlates honeypot file access with subsequent network activity (e.g., `curl` to a paste site or DNS resolution of exfiltration domains).
- **Goal:** Detecting data exfiltration in progress.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists (via `honeypot-deployer export-addresses`).
- **Detection:** Triggers when the non-funded honeypot address receives a balance query or an outbound transfer attempt on the blockchain.
- **Goal:** Confirmation of successful theft and monitoring of the attacker's on-chain infrastructure.

---

## MITRE ATT&CK Mapping

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

---

## Artifact Realism

To deceive sophisticated attackers and automated malware, the generated artifacts mimic real wallet structures:

- **Bitcoin:** Berkeley DB formatted `wallet.dat` files.
- **Ethereum:** Standard UTC/JSON keystore files.
- **Browser Extensions:** LevelDB (Chrome) and IndexedDB (Firefox) structures, including log files and manifests.
- **Seed Phrases:** BIP-39 compliant mnemonics in TXT, JSON, and PDF decoys.
