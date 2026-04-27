# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense system designed to detect and alert on unauthorized access to sensitive cryptocurrency-related files. It integrates with Wazuh SIEM to provide real-time monitoring and automated response.

## Detection Strategy

The system employs a 4-layer detection strategy to ensure high-fidelity alerts with zero false positives.

### Layer 1: File Integrity Monitoring (FIM)
The foundation of the honeypot is Wazuh's FIM (syscheck). Since legitimate users and processes should never access the honeypot files, any interaction (read, write, or delete) is a high-confidence indicator of malicious activity.
- **Mechanism:** Wazuh `syscheck` with `whodata="yes"`.
- **Target:** `wallet.dat`, `keystore` files, `.env` files, and browser extension storage.

### Layer 2: Process-Level Auditing
To provide context to FIM alerts, the system monitors process-level activity. This helps identify the specific tool or script used by an attacker.
- **Mechanism:** `auditd` on Linux, `Sysmon` on Windows.
- **Target:** Process names, parent processes, command-line arguments, and filesystem enumeration patterns.

### Layer 3: Network Correlation
Most attackers aim to exfiltrate stolen credentials. By correlating honeypot file access with subsequent network activity, we can identify exfiltration attempts.
- **Mechanism:** Wazuh log analysis of system calls and network connections.
- **Target:** Outbound connections to common exfiltration targets (e.g., Pastebin, GitHub, C2 servers) or unusual use of `curl`, `wget`, `scp`, or `ftp`.

### Layer 4: On-Chain Monitoring
The final layer of detection occurs outside the local system. By monitoring the public addresses associated with the honeypot's private keys, we can detect if an attacker successfully imports and attempts to use the stolen credentials.
- **Mechanism:** Block explorer watchlists and custom monitoring scripts.
- **Target:** Transaction history, balance checks, or token transfers on BTC, ETH, SOL, and other supported chains.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot provides coverage for several MITRE ATT&CK techniques across various stages of an attack.

| Technique ID | Technique Name | Detection Layer |
|--------------|----------------|-----------------|
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

## Data Flow

1. **Generation:** `honeypot-deployer` creates randomized wallet artifacts and an encrypted manifest.
2. **Deployment:** Artifacts are placed on monitored endpoints, and Wazuh/Audit rules are applied.
3. **Trigger:** An attacker accesses a honeypot file.
4. **Local Alert:** Wazuh Agent generates an event and sends it to the Wazuh Manager.
5. **Manager Analysis:** Wazuh Manager decodes the event and triggers a high-severity rule (100500+ series).
6. **Active Response:** (Optional) The manager triggers a forensic snapshot or user lockout on the endpoint.
7. **On-Chain Alert:** (If credentials are used) A block explorer watchlist notifies the security team of on-chain activity.
