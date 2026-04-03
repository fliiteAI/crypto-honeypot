# Architecture Overview: Crypto Wallet Honeypot

The Crypto Wallet Honeypot is a multi-layered defensive system designed to detect and alert on unauthorized access to cryptocurrency-related artifacts. It integrates with Wazuh SIEM to provide high-fidelity alerts with zero false positives.

## 4-Layer Detection Strategy

The system utilizes four distinct layers of detection to ensure that even sophisticated attackers are caught at various stages of their kill chain.

| Layer | Component | Detection Mechanism |
|-------|-----------|---------------------|
| **Layer 1** | Wazuh FIM | **File Integrity Monitoring:** Detects any read, modification, or deletion of honeypot files in real-time. |
| **Layer 2** | Auditd / Sysmon | **Process Auditing:** Captures the specific process and user responsible for accessing the honeypot, providing deep forensic context. |
| **Layer 3** | Network Correlation | **Exfiltration Detection:** Correlates honeypot access with subsequent network activity (e.g., DNS queries to paste sites, use of `curl` or `scp`). |
| **Layer 4** | On-Chain Monitoring | **Blockchain Watchlists:** Monitors the public addresses of generated honeypots for any on-chain activity, confirming that stolen keys are being used. |

## MITRE ATT&CK Mapping

The honeypot's detections map directly to several MITRE ATT&CK techniques, helping security teams understand the attacker's intent and progress.

| Technique | Name | Description |
|-----------|------|-------------|
| **T1083** | File and Directory Discovery | Attacker enumerating the filesystem and finding the honeypot files. |
| **T1005** | Data from Local System | Attacker reading the contents of the honeypot wallet files. |
| **T1555** | Credentials from Password Stores | Attacker targeting specific application credential stores like Electrum or Exodus. |
| **T1555.003** | Credentials from Web Browsers | Attacker extracting data from browser extension local storage (MetaMask, Phantom). |
| **T1560** | Archive Collected Data | Attacker staging the stolen files into an archive (zip, tar) before exfiltration. |
| **T1041** | Exfiltration Over C2 Channel | Attacker using an established C2 channel to exfiltrate the stolen keys. |
| **T1048** | Exfiltration Over Alternative Protocol | Attacker using tools like `curl` or `webhook.site` to move data off-host. |
| **T1657** | Financial Theft | Attacker initiating transactions on-chain using the stolen private keys. |

## Data Flow

1.  **Artifact Generation:** The `honeypot-deployer` CLI generates realistic, non-funded wallet artifacts and a secure manifest.
2.  **Deployment:** Artifacts are placed in standard locations on target endpoints (Linux/Windows).
3.  **Monitoring:** Wazuh agents monitor these paths using FIM and OS-level auditing (auditd/Sysmon).
4.  **Alerting:** Access triggers an event which is sent to the Wazuh Manager.
5.  **Correlation:** The Wazuh Manager applies custom rules to escalate events and trigger automated responses.
6.  **On-Chain Verification:** Public addresses from the manifest are imported into block explorer watchlists for final confirmation of theft.
