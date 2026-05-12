# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is a multi-layered defensive tool designed to detect and alert on unauthorized access to cryptocurrency wallet artifacts. It integrates with Wazuh SIEM to provide high-fidelity alerts with zero false positives.

## 4-Layer Detection Strategy

The system employs four distinct layers of detection to ensure comprehensive coverage against various attack vectors, from automated infostealers to manual intruders.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
**Mechanism:** Wazuh `syscheck` module.
- **What It Detects:** Any read, modification, or deletion of honeypot wallet files.
- **Implementation:** Configuration uses `whodata="yes"`, `realtime="yes"`, and `report_changes="yes"`.
- **Fidelity:** extremely high. Legitimate users have no reason to access these hidden/decoy paths.

### Layer 2: Process Auditing (Linux Auditd / Windows Sysmon)
**Mechanism:** Kernel-level process tracking.
- **What It Detects:** Process-level access to wallet paths, filesystem enumeration (e.g., `find`, `grep`, `ls`), and access by suspicious processes.
- **Implementation:**
    - **Linux:** Custom `auditd` rules (`-p r` for read access).
    - **Windows:** Sysmon Event ID 1 (Process creation) and Event ID 11 (FileCreate) filtered for honeypot paths.

### Layer 3: Network Correlation
**Mechanism:** Wazuh rule correlation.
- **What It Detects:** Outbound network activity occurring immediately after a honeypot access event.
- **Implementation:** Correlation rules (e.g., Rule 100520) trigger when a network-capable process (like `curl`, `wget`, or `python`) accesses a honeypot file and subsequently initiates a network connection.

### Layer 4: On-Chain Monitoring
**Mechanism:** Block explorer watchlists and custom monitoring scripts.
- **What It Detects:** The moment an attacker imports a stolen private key into a real wallet and performs an on-chain action (e.g., balance check, transfer).
- **Implementation:** Public addresses from the `manifest.json` are exported using `honeypot-deployer export-addresses` and imported into monitoring services.

---

## MITRE ATT&CK Mapping

The detection capabilities of this system map directly to several techniques within the MITRE ATT&CK framework:

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

## System Components

1.  **Honeypot Deployer CLI:** A Python application used to generate randomized, realistic artifacts and manage the deployment manifest.
2.  **Generators:** Chain-specific modules (BTC, ETH, SOL, etc.) that create the actual files (e.g., `wallet.dat`, `keystore.json`).
3.  **Wazuh Manager:** Receives logs, decodes them using custom decoders, and fires alerts based on specialized rule sets.
4.  **Wazuh Agent:** Installed on monitored endpoints; performs FIM and collects audit/Sysmon logs.
5.  **Manifest:** An encrypted JSON file that tracks all deployed honeypots, their locations, and their associated keys.
