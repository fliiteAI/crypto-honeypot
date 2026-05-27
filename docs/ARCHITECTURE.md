# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect, attribute, and respond to attackers targeting cryptocurrency assets on monitored endpoints.

## 4-Layer Detection Strategy

The system utilizes a "defense-in-depth" approach with four distinct layers of detection:

### Layer 1: File Integrity Monitoring (FIM)
The foundation of the system is Wazuh's FIM (syscheck) module.
- **Mechanism:** Monitors specific honeypot file paths for any read, modify, or delete operations.
- **Goal:** Provide immediate, high-fidelity alerts when an attacker touches a decoy wallet file.
- **Key Files:** `wallet.dat` (BTC), `keystore/` (ETH), `id.json` (SOL), browser extension data (MetaMask, Phantom).

### Layer 2: Process Auditing & Behavioral Analysis
Moving beyond simple file access, this layer uses `auditd` (Linux) and `Sysmon` (Windows) to provide context.
- **Mechanism:** Captures the PID, process name, and user ID associated with the honeypot access.
- **Goal:** Distinguish between automated infostealers (e.g., rapid access to multiple browser extension paths) and manual exploration by an intruder.
- **Detection:** Correlates file access with process capabilities (e.g., a process with network socket activity accessing a wallet).

### Layer 3: Network Correlation
Detects the exfiltration phase of an attack.
- **Mechanism:** Monitors for network connections to known paste sites, C2 IP addresses, or unusual outbound data transfers immediately following a honeypot trigger.
- **Goal:** Confirm exfiltration and identify the destination of the stolen (fake) credentials.

### Layer 4: On-Chain Monitoring
The final layer extends beyond the local network.
- **Mechanism:** Automated watchlists on public block explorers (via Etherscan, Solscan, etc.) for the generated honeypot public addresses.
- **Goal:** Detect when an attacker attempts to import the stolen private keys into a real wallet or query their balance on-chain.

---

## MITRE ATT&CK Mapping

The system's detections are mapped to confirmed MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## System Components

1.  **Honeypot Deployer (CLI):** A Python-based tool for generating realistic, randomized wallet artifacts and managing a secure manifest of private keys.
2.  **Wazuh Manager:** The central brain that receives logs, applies custom decoders and rules, and triggers alerts/active responses.
3.  **Wazuh Agents:** Installed on endpoints to perform FIM and log collection.
4.  **Auditd/Sysmon:** Provide deep system-level visibility required for Layer 2.
