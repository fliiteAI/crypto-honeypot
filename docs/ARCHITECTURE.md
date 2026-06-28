# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system is built on a "zero false positive" detection philosophy. It utilizes a four-layer detection strategy to catch attackers at various stages of the kill chain, from initial discovery to successful exfiltration and financial theft.

## Detection Strategy

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**Goal:** Detect any interaction with honeypot files.

Layer 1 provides the initial alert. By placing realistic-looking wallet files in standard locations (e.g., `~/.bitcoin/wallet.dat`), we ensure that any process or user attempting to read, modify, or delete these files triggers an alert.

- **Reliability:** Extremely high. Legitimate users and processes have no reason to access these specific paths.
- **Wazuh Rules:** 100501 - 100507

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**Goal:** Identify *who* and *how* the files were accessed.

While FIM tells us a file was touched, Layer 2 provides the forensic context. It captures the process ID, parent process, user account, and the exact command executed. This is crucial for distinguishing between an automated infostealer and a manual intruder.

- **MITRE Mapping:** T1083 (File and Directory Discovery)
- **Wazuh Rules:** 100510 - 100512

### Layer 3: Network Correlation
**Mechanism:** Wazuh log analysis / Network telemetry
**Goal:** Detect exfiltration of stolen data.

If an attacker reads a wallet file, their next step is almost always to move it off the machine. Layer 3 monitors for suspicious network activity following a honeypot access event, such as use of `curl`, `scp`, or DNS queries to known paste-sites.

- **MITRE Mapping:** T1041 (Exfiltration Over C2), T1048 (Exfiltration Over Alternative Protocol)
- **Wazuh Rules:** 100520 - 100522

### Layer 4: On-Chain Monitoring
**Mechanism:** Block explorer watchlists / Chain Monitor integration
**Goal:** Detect when stolen keys are actually used.

The final layer of detection occurs outside the compromised host. By monitoring the public addresses of the generated honeypots on their respective blockchains (BTC, ETH, SOL, etc.), we can detect when an attacker imports the keys and attempts to query balances or move funds.

- **MITRE Mapping:** T1657 (Financial Theft)
- **Wazuh Rules:** 100530 - 100533

---

## MITRE ATT&CK Mapping

The system provides coverage for the following techniques:

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

## Data Flow

1. **Generation:** `honeypot-deployer` creates unique wallet artifacts and an encrypted manifest.
2. **Deployment:** Artifacts are placed on endpoints; Wazuh Manager is updated with honeypot rules.
3. **Trigger:** Attacker accesses a file (Layer 1/2).
4. **Alert:** Wazuh Agent sends event to Manager; Manager fires alert (Layer 3 correlation).
5. **On-Chain:** Attacker uses keys; Chain Monitor triggers external alert (Layer 4).
