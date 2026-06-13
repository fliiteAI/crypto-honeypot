# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers (automated infostealers or manual intruders) targeting cryptocurrency assets. It employs a "zero false positive" strategy based on the principle that legitimate users and authorized processes have no reason to access the honeypot files.

## 4-Layer Detection Strategy

The system provides defense-in-depth through four distinct detection layers:

### Layer 1: File Integrity Monitoring (FIM)
- **Mechanism:** Wazuh FIM (syscheck) monitors the honeypot artifacts at rest.
- **Detection:** Triggers on any read, modification, or deletion of honeyfiles.
- **Goal:** Immediate notification of unauthorized filesystem interaction.

### Layer 2: Process & Command Auditing
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detection:** Captures the specific process (e.g., `curl`, `scp`, `python`) and user context involved in the access.
- **Goal:** Distinguish between automated scanners (infostealers) and manual exploration.

### Layer 3: Network Correlation
- **Mechanism:** Correlation of FIM/Audit events with network activity (DNS queries, outbound connections).
- **Detection:** High-severity alerts when a process accesses a honeypot and immediately performs network exfiltration (e.g., DNS query to `pastebin.com`).
- **Goal:** Detect active data theft and identify exfiltration channels.

### Layer 4: On-Chain Monitoring
- **Mechanism:** External "Chain Monitor" service tracking the public addresses of generated honeypots.
- **Detection:** Alerts when a honeypot's private key is imported into a real wallet and used to query balances or attempt transfers.
- **Goal:** Confirmation of successful key theft, even if endpoint-level exfiltration detection was bypassed.

## MITRE ATT&CK Mapping

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal on Host | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003**| Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

## Detection Logic Principle

The system is predicated on **high-fidelity alerts**. Because the honeypot files are placed in non-standard or hidden locations (e.g., `.bitcoin/wallet.dat`, `~/.config/solana/id.json`) and contain no real value, any interaction is considered malicious by default.
