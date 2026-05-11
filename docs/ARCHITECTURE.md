# Architecture Overview: Crypto Wallet Honeypot

This document describes the design principles, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## Detection Strategy: 4-Layer Defense

The system employs a multi-layered detection strategy to ensure high-fidelity alerts and comprehensive coverage of attacker activities.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
The primary detection mechanism. Wazuh's FIM engine monitors the honeypot artifact paths for any access.
- **Mechanism:** Real-time monitoring of files like `wallet.dat`, `keystore`, and browser extension storage.
- **Alert Types:** File added, modified, deleted, or read.
- **Goal:** Provide immediate notification of honeypot interaction.

### Layer 2: Process Auditing (auditd / Sysmon)
Provides context on *how* and *by whom* the honeypot was accessed.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **Alert Types:** Process execution, file read by specific PID/User, command-line arguments.
- **Goal:** Identify the specific tool (e.g., `cat`, `scp`, or a malicious infostealer binary) used by the attacker.

### Layer 3: Network Correlation
Tracks data exfiltration attempts following honeypot access.
- **Mechanism:** Correlation of FIM alerts with outbound network connections to known exfiltration sites (e.g., Pastebin, Telegram API, or common C2 patterns).
- **Goal:** Detect the movement of stolen "credentials" out of the network.

### Layer 4: On-Chain Monitoring
The final layer of detection, providing 100% certainty of theft.
- **Mechanism:** Monitoring the public addresses of the generated honeypot keys on their respective blockchains (BTC, ETH, SOL, etc.).
- **Goal:** Detect when an attacker imports the stolen keys and attempts to check balances or move funds.

---

## MITRE ATT&CK Mapping

The Crypto Wallet Honeypot system maps to the following MITRE ATT&CK techniques:

| ID | Technique Name | Detection Layer | Description |
|----|----------------|-----------------|-------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 | Attacker enumerating the filesystem and finding "interesting" wallet files. |
| **T1005** | Data from Local System | Layer 1 | Attacker collecting honeypot artifacts. |
| **T1555** | Credentials from Password Stores | Layer 1 | Accessing files that appear to be password or key stores. |
| **T1555.003** | Credentials from Web Browsers | Layer 1 | Accessing browser extension wallet data (MetaMask, etc.). |
| **T1560** | Archive Collected Data | Layer 2, 3 | Attacker zipping or tarring the honeyfiles for exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 | Sending stolen keys to a command and control server. |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 | Using protocols like HTTP/S or FTP to exfiltrate data. |
| **T1657** | Financial Theft | Layer 4 | Attacker attempting to use stolen private keys on-chain. |
| **T1070** | Indicator Removal | Layer 1 | Attacker attempting to delete the honeypot files to hide their presence. |

---

## Component Interaction

1. **Honeypot Deployer (CLI):** Generates artifacts and provides the Wazuh configuration.
2. **Wazuh Agent:** Monitors the filesystem and process activity on the endpoint.
3. **Wazuh Manager:** Receives logs from agents, applies custom decoders and rules, and triggers alerts.
4. **On-Chain Monitor:** Uses public block explorers or nodes to watch honeypot addresses.
5. **Security Operations Center (SOC):** Receives high-fidelity alerts with near-zero false positives, as legitimate users should never interact with these files.
