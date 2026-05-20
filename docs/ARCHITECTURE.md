# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles, detection strategy, and technical implementation of the Crypto Wallet Honeypot system.

## Detection Strategy: The 4-Layer Approach

The system employs a multi-layered detection strategy to ensure high-fidelity alerts and comprehensive coverage of attacker activities.

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) with `whodata` enabled.
- **Goal:** Detect any read, modification, or deletion of honeypot files.
- **Benefit:** Provides immediate alerts when an attacker or malware touches a decoy file.

### Layer 2: Process & Command Auditing
- **Mechanism:** `auditd` on Linux, Sysmon on Windows.
- **Goal:** Attribute file access to specific processes and users.
- **Benefit:** Distinguishes between manual exploration and automated infostealer activity. Detects rapid, sequential access to multiple wallet paths.

### Layer 3: Network Correlation
- **Mechanism:** Wazuh log collection + network-capable process monitoring.
- **Goal:** Correlate honeypot access with suspicious network activity.
- **Benefit:** Detects exfiltration attempts (e.g., `curl` or `scp` following a wallet access event) or DNS queries to known paste sites.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External block explorer watchlists + `chain-monitor` integration.
- **Goal:** Detect when stolen keys are imported and used on-chain.
- **Benefit:** Provides definitive proof of theft even if the attacker bypasses host-level monitoring.

---

## MITRE ATT&CK Mapping

The honeypot system is designed to detect and alert on several MITRE ATT&CK techniques:

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

---

## Component Architecture

1. **`honeypot-deployer` CLI:** A Python application used to generate randomized, realistic artifacts and manage encrypted manifests.
2. **Honeypot Artifacts:** Decoy files (BTC `wallet.dat`, ETH keystores, etc.) placed on endpoints.
3. **Wazuh Agent:** Monitors the artifacts using FIM and audit rules.
4. **Wazuh Manager:** Processes events from agents, applies custom decoders and rules, and triggers alerts.
5. **Encrypted Manifest:** A secure file tracking all deployed honeypots, used for health checks and on-chain monitoring setup.
