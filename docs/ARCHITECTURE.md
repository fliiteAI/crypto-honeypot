# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is designed to provide high-fidelity detection of attackers targeting cryptocurrency assets. It employs a multi-layered detection strategy that spans from local filesystem access to on-chain activity.

## 4-Layer Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Description:** Monitors specific honeypot file paths for any read, modification, or deletion events.
**What It Detects:** Direct access to wallet files (e.g., `wallet.dat`, `keystore`, `id.json`) by an attacker or automated malware.

### Layer 2: Process Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Description:** Provides deep visibility into *which* process and *which* user accessed the honeypot files.
**What It Detects:** Process-level access patterns, filesystem enumeration, and attempts to read sensitive files using system utilities (e.g., `cat`, `type`, `copy`).

### Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis / Network Monitoring
**Description:** Correlates honeypot file access with subsequent network activity.
**What It Detects:** Exfiltration attempts (e.g., `curl` to a paste site, `scp` to an external IP, or DNS tunneling) occurring shortly after honeypot access.

### Layer 4: On-Chain Monitoring
**Mechanism:** Block Explorer Watchlists / On-Chain APIs
**Description:** Monitors the public addresses of the generated honeypot keys for any activity on the blockchain.
**What It Detects:** The ultimate success of an attack—when the attacker imports the stolen keys into a wallet and attempts to query the balance or transfer funds.

---

## MITRE ATT&CK Mapping

The system provides coverage for the following MITRE ATT&CK techniques:

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

## Component Diagram

1.  **Honeypot Deployer (CLI):** Generates randomized artifacts and encrypted manifest.
2.  **Target Endpoints:** Host the honeypot files and run the Wazuh Agent + `auditd`/Sysmon.
3.  **Wazuh Manager:** Receives events, applies custom decoders/rules, and triggers alerts.
4.  **On-Chain Monitor:** Uses exported addresses to track activity on the blockchain.
