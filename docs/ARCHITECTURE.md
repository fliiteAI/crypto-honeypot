# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity, zero-false-positive detection of attackers targeting cryptocurrency assets. It employs a 4-layer detection strategy to catch intruders at various stages of the attack lifecycle.

## Detection Strategy

### Layer 1: File Access Detection (FIM)
This layer uses Wazuh's File Integrity Monitoring (FIM) to detect any read, modification, or deletion of honeypot wallet files. Since legitimate users and processes have no reason to access these files, any activity is considered high-fidelity evidence of an intruder.

### Layer 2: Process & Command Auditing
On Linux, `auditd` is used to track which process and user accessed the honeypot files. On Windows, Sysmon provides similar process-level visibility. This layer helps identify the tools used by the attacker (e.g., `cat`, `grep`, or custom infostealer malware).

### Layer 3: Network Correlation
This layer correlates honeypot file access with subsequent network activity, such as DNS queries to paste sites or outbound connections using tools like `curl` or `scp`. This provides evidence of data exfiltration.

### Layer 4: On-Chain Monitoring
By monitoring the public addresses of the generated honeypot keys on the blockchain (BTC, ETH, SOL, etc.), we can detect when an attacker imports the stolen keys into a wallet and attempts to query balances or move funds.

## MITRE ATT&CK Mapping

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

## Zero False Positive Philosophy
The system is predicated on the rule that **legitimate users and authorized processes have no reason to access the honeypot files**. Any access is, by definition, unauthorized, allowing for high-confidence alerting and automated active response.
