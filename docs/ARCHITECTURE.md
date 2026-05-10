# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system employs a multi-layered detection strategy designed to catch attackers at various stages of the kill chain, from initial discovery to successful exfiltration and financial theft.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense is Wazuh's FIM (syscheck) module. We deploy realistic-looking but fake wallet artifacts across the filesystem.
- **Mechanism:** Wazuh monitors specific honeypot paths (e.g., `~/.bitcoin/wallet.dat`).
- **Detection:** Any `read`, `write`, or `delete` operation on these files triggers an immediate high-severity alert.
- **Target:** Detecting manual discovery and automated infostealers.

### Layer 2: Process & Command Auditing
While FIM detects *that* a file was accessed, Layer 2 provides the *context* of the access.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Detection:** Captures the PID, parent process, user, and exact command line used to access the honeypot.
- **Target:** Attributing access to specific software (e.g., a suspicious Python script or `curl`) or user sessions.

### Layer 3: Network Correlation
Detects the movement of stolen data after it has been read from the filesystem.
- **Mechanism:** Correlating honeypot file access events with subsequent network activity.
- **Detection:**
  - Network-capable processes (e.g., `curl`, `scp`) accessing honeypots.
  - DNS queries to common exfiltration sites (e.g., Pastebin, Telegram API) following a honeypot access event.
  - Usage of archival tools (`zip`, `tar`) to stage honeypot data.
- **Target:** Detecting the exfiltration phase of an attack.

### Layer 4: On-Chain Monitoring
The final layer monitors the public blockchain for any activity involving the honeypot's public addresses.
- **Mechanism:** Integration with block explorers via the `chain-monitor` service.
- **Detection:**
  - Balance queries on honeypot addresses.
  - Inbound transfers (attacker testing the key).
  - Outbound transfers (active theft attempt).
- **Target:** Providing definitive proof of compromise even if host-based detection is bypassed or logs are cleared.

---

## MITRE ATT&CK Mapping

The system is designed to provide coverage across several MITRE ATT&CK techniques:

| ID | Technique Name | Detection Layer |
|----|----------------|-----------------|
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

## System Integration

1. **Honeypot Deployer:** Generates randomized, realistic artifacts and a secure manifest.
2. **Wazuh Agent:** Monitors the host using FIM and Audit rules.
3. **Wazuh Manager:** Processes logs, applies custom decoders and rules, and triggers alerts.
4. **Active Response:** Executes automated forensic snapshots when alerts are triggered.
5. **Chain Monitor:** (Optional) Feeds blockchain activity logs into Wazuh for Layer 4 detection.
