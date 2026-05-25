# Architecture Overview: Crypto Wallet Honeypot

This document describes the architectural design, detection strategy, and MITRE ATT&CK mapping for the Crypto Wallet Honeypot system.

## Detection Strategy

The system utilizes a 4-layer detection strategy to ensure high-fidelity alerts and comprehensive coverage of attacker activities.

### Layer 1: Wazuh FIM (File Integrity Monitoring)
**Mechanism:** Real-time monitoring of honeypot wallet files.
**Description:** Wazuh FIM tracks any access (read, modify, or delete) to the decoy files. Since these files are never used by legitimate users or processes, any interaction is considered highly suspicious.
**What It Detects:** Direct interaction with honeypot wallet files.

### Layer 2: Process Auditing (Linux auditd / Windows Sysmon)
**Mechanism:** Process-level monitoring of filesystem activity.
**Description:** Uses `auditd` on Linux and `Sysmon` on Windows to capture which process accessed a honeypot path. This provides context, such as identifying if a web browser, a shell, or a known malware process is responsible.
**What It Detects:** Process-level access, filesystem enumeration, and "who" performed the action.

### Layer 3: Network Correlation
**Mechanism:** Correlating honeypot access with network activity.
**Description:** Monitors for common exfiltration patterns (e.g., use of `curl`, `scp`, or connections to known paste sites) shortly after a honeypot file has been accessed.
**What It Detects:** Exfiltration attempts and C2 communication.

### Layer 4: On-Chain Monitoring
**Mechanism:** Tracking public addresses of generated honeypot keys.
**Description:** By monitoring the public addresses associated with the honeypot keys on their respective blockchains (e.g., via block explorers or node monitoring), we can detect if an attacker has successfully imported and attempted to use the stolen credentials.
**What It Detects:** Successful credential theft and subsequent on-chain activity.

## MITRE ATT&CK Mapping

The system's detections are mapped to the following MITRE ATT&CK techniques:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

## Component Overview

- **`honeypot-deployer` CLI:** A Python application that generates randomized, realistic crypto wallet artifacts and manages an encrypted manifest.
- **Artifact Generators:** Chain-specific modules (BTC, ETH, SOL, XRP, ADA, etc.) that create valid-format but non-funded wallet files.
- **Wazuh SIEM:** The central monitoring and alerting platform.
- **Custom Wazuh Rules/Decoders:** Tailored configuration for detecting honeypot-specific events.
- **Active Response:** Automated scripts that trigger upon detection (e.g., taking a forensic snapshot).
