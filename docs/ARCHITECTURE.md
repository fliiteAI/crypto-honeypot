# System Architecture: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers and malware targeting cryptocurrency assets. It uses a multi-layered approach to ensure that any interaction with the honeypot artifacts triggers an alert.

## Detection Strategy

The system utilizes a 4-layer detection strategy:

### Layer 1: Wazuh FIM (File Integrity Monitoring)
This is the primary detection mechanism. Wazuh monitors specific honeypot files for any read, modify, or delete operations.
- **Mechanism:** Wazuh `syscheck` with `realtime="yes"` and `whodata="yes"`.
- **Target:** Wallet files (`wallet.dat`, `keystore`, `id.json`), seed phrases, and browser extension data.

### Layer 2: Process Auditing
To provide context to the file access, the system monitors process-level activity.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Detection:** Identification of the specific process (e.g., `curl`, `scp`, `python`, `powershell`) that accessed the honeypot files.

### Layer 3: Network Correlation
Detects exfiltration attempts that occur immediately after honeypot access.
- **Mechanism:** Correlation of FIM events with network connection logs.
- **Detection:** Outbound connections to known paste sites, C2 servers, or unusual remote IPs following a wallet access event.

### Layer 4: On-Chain Monitoring
The final layer monitors the public addresses associated with the honeypot private keys for any on-chain activity.
- **Mechanism:** Watchlists on block explorers (e.g., Etherscan, Solscan, Blockchain.com).
- **Detection:** Alerts when the honeypot addresses receive or send funds, indicating the attacker has successfully imported the stolen keys.

## MITRE ATT&CK Mapping

The honeypot system detects several techniques defined in the MITRE ATT&CK framework:

| ID | Name | Description |
|----|------|-------------|
| **T1005** | Data from Local System | Accessing honeypot wallet files on the local filesystem. |
| **T1070** | Indicator Removal | Deletion of honeypot artifacts to hide presence. |
| **T1555** | Credentials from Password Stores | Accessing stored wallet credentials. |
| **T1555.003** | Credentials from Web Browsers | Accessing browser-based wallet extensions (MetaMask, Phantom). |
| **T1083** | File and Directory Discovery | Automated scanning or manual enumeration of sensitive paths. |
| **T1041** | Exfiltration Over C2 Channel | Sending stolen keys to an attacker-controlled server. |
| **T1048** | Exfiltration Over Alternative Protocol | Exfiltrating data via common tools like `curl` or `scp`. |
| **T1560** | Archive Collected Data | Compression of honeypot files before exfiltration. |
| **T1657** | Financial Theft | Final on-chain movement of funds from stolen accounts. |
