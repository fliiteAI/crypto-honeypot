# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a 4-layer detection strategy designed to detect, correlate, and alert on unauthorized access to cryptocurrency assets.

## Detection Layers

| Layer | Component | Mechanism | Description |
|-------|-----------|-----------|-------------|
| **Layer 1** | Wazuh FIM | File Integrity Monitoring | Detects the moment a honeypot file is accessed, modified, or deleted. High-fidelity alerts with zero false positives. |
| **Layer 2** | Linux Auditd / Windows Sysmon | Process Auditing | Identifies *which* process accessed the honeypot. Detects infostealer behavior (rapid sequential access) and filesystem enumeration. |
| **Layer 3** | Wazuh Rules | Network Correlation | Correlates honeypot access with network-capable processes (curl, scp) or DNS queries to exfiltration sites (pastebin, etc.). |
| **Layer 4** | Chain Monitor | On-Chain Monitoring | Detects if an attacker imports stolen keys and interacts with them on-chain (balance queries, transfers). |

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
At the core of the system is the principle that **legitimate users never access honeypot files**. We use Wazuh's FIM module with `whodata="yes"` to monitor specific, high-value paths where wallets are typically stored.

### Layer 2: Process-Level Visibility
While FIM tells us *that* a file was accessed, Layer 2 tells us *who* or *what* did it. By using `auditd` on Linux and Sysmon on Windows, we can capture the process name, command line, and parent process, allowing us to distinguish between a curious user and automated malware.

### Layer 3: Exfiltration Correlation
Attackers often use specific tools or patterns to exfiltrate stolen data. Layer 3 monitors for the use of network utilities (curl, wget) or archiving tools (zip, tar) immediately following honeypot access.

### Layer 4: On-Chain Canary Addresses
The final layer of defense is on the blockchain itself. Each honeypot artifact contains a unique, non-funded private key tracked in our manifest. If an attacker imports this key into their own wallet, any on-chain activity will trigger an alert, confirming a successful exfiltration and identifying the attacker's intent.

## MITRE ATT&CK Mapping

The system is mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal on Host | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
