# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## Detection Strategy

The system employs a 4-layer detection strategy to ensure high-fidelity alerts and minimize false positives.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The primary detection layer. Wazuh monitors the honeypot artifacts for any access (read), modification, or deletion.
- **Principle:** Legitimate users and processes have no reason to access these hidden or specifically named honeyfiles.
- **Configuration:** Uses `whodata="yes"`, `realtime="yes"`, and `report_changes="yes"` for maximum visibility and attribution.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
Provides deeper visibility into *what* process accessed the honeypot and *how*.
- **Linux:** Uses `auditd` rules (`-p rwa`) to track file access and attribute it to a specific User ID (UID) and Process ID (PID).
- **Windows:** Uses Sysmon to capture process creation and file access events, including the parent process and command-line arguments.

### Layer 3: Network Correlation
Monitors for suspicious network activity immediately following a honeypot access event.
- **Indicators:** Usage of `curl`, `wget`, `scp`, or connections to known paste sites (Pastebin, Ghostbin) or C2 infrastructure.
- **Implementation:** Wazuh rules correlate FIM/Audit events with subsequent network events from the same PID or user.

### Layer 4: On-Chain Monitoring
The final layer of detection that tracks the movement of funds or keys if the honeypot artifacts are successfully exfiltrated and used.
- **Mechanism:** Honeypot public addresses are added to watchlists on block explorers (Etherscan, Solscan, etc.) or specialized chain monitoring tools.
- **Trigger:** Any on-chain transaction or even a simple balance query on a bait address indicates that the keys have been imported into an attacker's wallet.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for several techniques used by infostealers and manual intruders.

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

1. **`honeypot-deployer` CLI:** Generates randomized, realistic artifacts and an encrypted manifest.
2. **Endpoint Artifacts:** Deployed to standard wallet and browser paths on monitored hosts.
3. **Wazuh Agent:** Monitors these paths using FIM and Auditd/Sysmon.
4. **Wazuh Manager:** Receives logs, applies custom decoders and rules, and triggers alerts.
5. **Active Response:** (Optional) Executes forensic collection scripts upon high-severity alerts.
6. **Watchlist Integration:** Public addresses from the manifest are exported for external chain monitoring.
