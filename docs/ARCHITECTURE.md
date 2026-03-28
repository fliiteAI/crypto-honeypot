# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware targeting cryptocurrency assets. It integrates with Wazuh SIEM to provide real-time alerting and automated response.

## 4-Layer Detection Strategy

Our defense-in-depth strategy utilizes four distinct layers to catch attackers at different stages of their lifecycle.

### Layer 1: File Integrity Monitoring (FIM)
The foundation of the system is Wazuh's FIM (syscheck). By deploying realistic-looking wallet files (e.g., `wallet.dat`, `keystore`, `id.json`) to standard locations, we create a "tripwire".
- **Mechanism:** Wazuh `syscheck` monitors honeypot paths.
- **Detection:** Any read, modification, or deletion of these files triggers an alert.
- **Goal:** Immediate notification of file-level interest from an attacker or infostealer.

### Layer 2: Process Auditing
This layer provides context to file access by identifying *which* process accessed the honeypot.
- **Mechanism:** Linux `auditd` and Windows `Sysmon`.
- **Detection:** Captures the process name, command line, and user ID responsible for the access.
- **Goal:** Distinguish between a manual explorer (e.g., `ls`, `cat`) and automated malware (e.g., custom infostealer binaries).

### Layer 3: Network Correlation
Detects the exfiltration phase by monitoring network activity following a honeypot access event.
- **Mechanism:** Monitoring DNS queries and outbound connections from processes that touched honeypots.
- **Detection:** Use of `curl`, `wget`, or connections to paste sites (Pastebin, Webhook.site) shortly after touching a wallet.
- **Goal:** Confirm data theft and identify the attacker's command-and-control (C2) infrastructure.

### Layer 4: On-Chain Monitoring
The final layer of detection occurs outside the local system, on the blockchain itself.
- **Mechanism:** Tracking the public addresses of generated honeypots on-chain.
- **Detection:** Any transaction activity or balance queries on these addresses.
- **Goal:** Detect if an attacker successfully exported and imported the keys, even if they bypassed local endpoint monitoring.

## MITRE ATT&CK Mapping

The system's detection rules are mapped to the following MITRE ATT&CK techniques:

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

## Integration with Wazuh

The system leverages Wazuh's powerful ruleset and active response capabilities:
1. **Custom Decoders:** Parse specialized logs from the honeypot deployer and chain monitor.
2. **High-Severity Rules:** Custom rules (IDs 100500+) generate alerts from Level 10 to 15.
3. **Active Response:** Automated scripts can trigger forensic snapshots or account lockouts upon honeypot access.
