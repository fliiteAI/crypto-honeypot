# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware targeting cryptocurrency assets. It employs a layered defense strategy that covers the entire lifecycle of a credential theft attack.

## 4-Layer Detection Strategy

The system is built on four distinct detection layers, each providing unique visibility and defense-in-depth.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** This is the primary detection layer. It monitors the honeypot artifact files (wallet.dat, keystores, seed phrases) for any access.
- **Detections:** File reads, modifications, and deletions.
- **Implementation:** Configured via `ossec.conf` on the Wazuh agent.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Provides context for file access events by identifying the specific process and user responsible.
- **Detections:** Process-level access to honeypot paths, filesystem enumeration (e.g., `find`, `ls`, `grep` on wallet directories).
- **Implementation:** Custom audit rules (`honeypot.rules`) and Sysmon configurations.

### Layer 3: Network Correlation
**Mechanism:** Wazuh Ruleset Correlation
**Description:** Monitors for exfiltration behavior following a honeypot access event.
- **Detections:** Use of network-capable tools (e.g., `curl`, `scp`, `python`) by a process that touched a honeypot; DNS queries to common exfiltration sites (pastebins, file-sharing sites).
- **Implementation:** State-based rules in `honeypot_rules.xml`.

### Layer 4: On-Chain Monitoring
**Mechanism:** External Chain Monitor Service
**Description:** Monitors the public blockchain addresses associated with the honeypot keys.
- **Detections:** Balance queries, token approvals, or outbound transfers from the honeypot addresses. This confirms the attacker has successfully exported and imported the stolen keys.
- **Implementation:** Integrates with Wazuh via the `chain-monitor` log source.

---

## MITRE ATT&CK Mapping

The system detects techniques across several stages of the MITRE ATT&CK framework.

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

## The "Zero False Positive" Philosophy

The core design principle of this system is that **legitimate users and authorized processes have no reason to access the honeypot files.**

Because the honeypots are placed in randomized or specific hidden locations that do not interfere with normal system operation, any access event is inherently suspicious. This allows security teams to treat honeypot alerts with the highest priority (Level 12+), enabling automated responses (like account lockout or forensic snapshots) with extremely high confidence.
