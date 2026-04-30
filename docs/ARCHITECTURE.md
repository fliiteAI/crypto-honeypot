# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot system implements a multi-layered defense-in-depth strategy to detect and track attackers targeting cryptocurrency assets. By deploying realistic, non-funded wallet artifacts across an organization's endpoints, we create "tripwires" that trigger alerts with near-zero false positives.

## 4-Layer Detection Strategy

The system is designed around four distinct detection layers, moving from local file access to global blockchain activity.

### Layer 1: File Integrity Monitoring (FIM)
**Mechanism:** Wazuh FIM (syscheck)
**What it detects:** Any read, modification, or deletion of honeypot files.
**Implementation:** Wazuh agents monitor specific paths where crypto wallets are traditionally stored (e.g., `~/.bitcoin/wallet.dat`, Chrome extension storage).
**Benefit:** Provides the first line of defense. Since no legitimate user or process should ever access these files, any FIM event on these paths is considered high-fidelity.

### Layer 2: Process & Command Auditing
**Mechanism:** Linux `auditd` / Windows Sysmon
**What it detects:** The specific process and user responsible for accessing the honeypot.
**Implementation:** Custom audit rules (Linux) or Sysmon configuration (Windows) capture the `execve` and file access events.
**Benefit:** Adds critical context to Layer 1 alerts. It allows us to distinguish between a manual attacker using `cat` and an automated infostealer like `RedLine` or `Raccoon`.

### Layer 3: Network Correlation
**Mechanism:** Wazuh Log Analysis & Network Monitoring
**What it detects:** Exfiltration attempts following a honeypot access event.
**Implementation:** Wazuh correlates file access events with subsequent network activity (e.g., `curl` to a paste site, DNS queries to known exfiltration domains).
**Benefit:** Confirms the attacker's intent and provides information on where the stolen data is being sent.

### Layer 4: On-Chain Monitoring
**Mechanism:** External Chain Monitor Service -> Wazuh
**What it detects:** Attacker importing the stolen private keys and interacting with the blockchain.
**Implementation:** Public addresses associated with the honeypot artifacts are added to watchlists on block explorers (via APIs like Etherscan, Solscan). When activity occurs, an alert is fed back into Wazuh.
**Benefit:** Provides definitive proof of successful exfiltration and allows for tracking the attacker's movement across the crypto ecosystem.

---

## MITRE ATT&CK Mapping

The system detects techniques across several stages of the attack lifecycle:

| ID | Technique | Detection Layer |
|----|-----------|-----------------|
| **T1083** | File and Directory Discovery | Layer 1, 2 |
| **T1005** | Data from Local System | Layer 1 |
| **T1555** | Credentials from Password Stores | Layer 1 |
| **T1555.003** | Credentials from Web Browsers | Layer 1 |
| **T1560** | Archive Collected Data | Layer 2 |
| **T1041** | Exfiltration Over C2 Channel | Layer 3 |
| **T1048** | Exfiltration Over Alternative Protocol | Layer 3 |
| **T1657** | Financial Theft | Layer 4 |
| **T1070** | Indicator Removal | Layer 1 |

---

## System Components

1. **`honeypot-deployer` CLI:** A Python application used to generate randomized, realistic wallet artifacts and manage the deployment manifest.
2. **Honeypot Artifacts:** The actual decoy files (wallet.dat, keystores, .env files) placed on target systems.
3. **Wazuh Manager:** The central SIEM that receives logs from agents, applies custom decoders and rules, and triggers alerts.
4. **Wazuh Agents:** Installed on endpoints to perform FIM and log collection.
5. **Auditd/Sysmon:** System-level auditing tools that provide process-level visibility.
6. **Chain Monitor (Optional):** A service that watches the blockchain for activity on generated honeypot addresses.
