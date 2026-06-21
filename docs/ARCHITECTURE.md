# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection strategy, and security philosophy of the Crypto Wallet Honeypot system.

## Detection Strategy: The 4-Layer Defense

The system employs a multi-layered approach to detect attackers at different stages of their lifecycle, from initial discovery to successful exfiltration and monetization.

### Layer 1: File Integrity Monitoring (FIM)
The first line of defense is Wazuh's FIM (syscheck). By monitoring the honeypot files for any access (read, modify, or delete), we get immediate visibility into an attacker's presence.
- **Mechanism:** Wazuh `syscheck` with `whodata` enabled.
- **What it detects:** Direct interaction with honeyfiles.
- **Value:** High-fidelity, immediate alerts.

### Layer 2: Process & Command Auditing
While FIM tells us *which* file was accessed, Layer 2 tells us *how* and by *whom*.
- **Mechanism:** `auditd` on Linux and `Sysmon` on Windows.
- **What it detects:** The specific process (e.g., `python`, `curl`, `powershell`) that touched the honeypot, the parent process, and the command-line arguments used.
- **Value:** Provides context for attribution and helps distinguish between automated infostealers and manual intruders.

### Layer 3: Network Correlation
This layer correlates honeypot file access with network activity to detect exfiltration.
- **Mechanism:** Wazuh rule correlation.
- **What it detects:** Network-capable processes (like `curl` or `scp`) accessing honeypots, or DNS queries to known paste sites/exfiltration points immediately following honeypot access.
- **Value:** Confirms that the data was not just accessed, but likely moved off the system.

### Layer 4: On-Chain Monitoring
The final layer moves beyond the endpoint and into the blockchain itself.
- **Mechanism:** Blockchain watchlists (Etherscan, Solscan, etc.) and the `chain-monitor` integration.
- **What it detects:** The attacker importing the stolen private keys into a wallet and checking balances or attempting transfers.
- **Value:** Provides definitive proof of successful theft and allows tracking of the attacker's financial trail even after they have left the compromised network.

---

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1005** | Data from Local System | Layer 1, 2 |
| **T1070** | Indicator Removal | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1083** | File and Directory Discovery | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1560** | Archive Collected Data | Layer 2, 3 |
| **T1657** | Financial Theft | Layer 4 |

---

## The "Zero False Positive" Philosophy

The core design principle of this honeypot is the **Zero False Positive** goal.

In a traditional security environment, distinguishing between legitimate administrative activity and malicious behavior can be difficult. However, the Crypto Wallet Honeypot is deployed in paths where **no legitimate user or authorized process should ever venture**.

For example, a legitimate developer has no reason to access a `.bitcoin/wallet.dat` file in their home directory if they don't use Bitcoin, and an automated backup script can be explicitly excluded from monitoring. Therefore, any access to these files is, by definition, unauthorized and suspicious.

By focusing on these "dead zones," the system provides high-confidence alerts that security teams can act upon immediately without the fatigue of tuning out noise.
