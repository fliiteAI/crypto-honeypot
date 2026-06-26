# Architectural Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed for high-fidelity detection of attackers and malware targeting cryptocurrency assets. It operates on a "zero false positive" principle: legitimate users and authorized processes have no reason to access the generated honeypot files.

## 4-Layer Detection Strategy

The system provides defense-in-depth across four distinct layers of the attack lifecycle.

### Layer 1: File Integrity Monitoring (FIM)
This is the primary detection layer. Wazuh FIM (syscheck) monitors the honeypot paths for any file system activity.
- **Mechanism:** Wazuh Agent `syscheck` with `whodata` enabled.
- **Detections:** File read, modification, creation, or deletion.
- **Goal:** Immediate alert when any honeypot file is touched.

### Layer 2: Process and Command Auditing
Provides context on *how* the files were accessed and *what* the attacker did next.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detections:** Process names, parent processes, command-line arguments, and user attribution.
- **Goal:** Distinguish between a manual intruder using `cat` or `type` and automated malware like an infostealer.

### Layer 3: Network Correlation
Tracks data exfiltration attempts following honeypot access.
- **Mechanism:** Correlation of FIM/Audit events with outbound network connections (e.g., to paste sites, C2 servers, or known exfiltration endpoints).
- **Detections:** Use of `curl`, `wget`, `scp`, or archive utilities (`zip`, `tar`) within a short time window after honeypot access.
- **Goal:** Confirm exfiltration of stolen credentials.

### Layer 4: On-Chain Monitoring
Provides "post-exfiltration" visibility if the attacker successfully steals and imports the honeypot keys.
- **Mechanism:** Automated watching of the honeypot's public addresses on their respective blockchains (BTC, ETH, SOL, etc.).
- **Detections:** Balance queries, incoming transfers (dusting), or outgoing transfers.
- **Goal:** Track the attacker's activity even after they have left the compromised endpoint.

---

## MITRE ATT&CK Mapping

The honeypot system provides coverage for the following MITRE ATT&CK techniques:

| ID | Name | Phase | Detection Layer |
|----|------|-------|-----------------|
| **T1083** | File and Directory Discovery | Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Collection | Layer 1 |
| **T1555** | Credentials from Password Stores | Credential Access | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Credential Access | Layer 1 |
| **T1560** | Archive Collected Data | Collection | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Exfiltration | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Exfiltration | Layer 3 |
| **T1657** | Financial Theft | Impact | Layer 4 |
| **T1070** | Indicator Removal | Defense Evasion | Layer 1 |

## Design Philosophy

1. **Realistic Artifacts:** Honeypot files (like `wallet.dat` or Ethereum keystores) are generated with valid structures to bypass basic validation by infostealers.
2. **Enticing Placement:** Deployed in standard paths where wallets are naturally found (e.g., `%APPDATA%`, `~/.config`).
3. **Passive Detection:** The system does not actively "trap" the attacker but monitors existing OS/SIEM hooks to remain lightweight and stealthy.
4. **Low Maintenance:** Once deployed, the system requires no interaction unless an alert is fired.
