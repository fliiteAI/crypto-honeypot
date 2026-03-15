# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** Version 4.x or higher.
  - **Recommended Hardware (SMB):** Raspberry Pi 4 (8GB) or Raspberry Pi 5 (8GB) for a dedicated, low-cost security appliance.
- **Wazuh Agent:** Version 4.x or higher installed on all target endpoints.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for `whodata` FIM support and user attribution).
- **Permissions:** `sudo` privileges are required for:
  - Modifying `/var/ossec/etc/ossec.conf`
  - Installing audit rules in `/etc/audit/rules.d/`
  - Restarting the `wazuh-agent` and `auditd` services.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.
- **Permissions:** Administrator privileges are required for:
  - Modifying `C:\Program Files (x86)\ossec-agent\ossec.conf`
  - Deploying artifacts to system or other users' `%APPDATA%` directories.

---

## Browser Extension Path Mappings

The honeypot targets common cryptocurrency wallet extensions. Below are the standard paths for different browsers and operating systems.

### Chrome-based (Chrome, Edge, Brave)
Chrome-based browsers use the same internal structure for extension storage. Replace `<ExtensionID>` with the specific ID (e.g., `nkbihfbeogaeaoehlefnkodbefgpgknn` for MetaMask).

- **Windows:** `%LOCALAPPDATA%\[Browser]\User Data\Default\Local Extension Settings\<ExtensionID>`
- **Linux:** `~/.config/[browser]/Default/Local Extension Settings/<ExtensionID>`

| Browser | Path Fragment (`[Browser]`) |
|---------|-----------------------------|
| Google Chrome | `Google\Chrome` (Win) / `google-chrome` (Linux) |
| Microsoft Edge | `Microsoft\Edge` |
| Brave Browser | `BraveSoftware\Brave-Browser` |

### Firefox
Firefox uses a different storage mechanism. Paths include a randomized profile string.

- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\<profile>\storage\default\moz-extension+++<ExtensionID>`
- **Linux:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<ExtensionID>`

---

## Wazuh Manager Configuration

Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

### 1. Install Decoders
Copy the custom decoders to your Wazuh Manager:
```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

### 2. Install Rules
Copy the custom rules to your Wazuh Manager:
```bash
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 3. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Configure the active response in your `ossec.conf` on the manager.

### 4. Restart Wazuh Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
`auditd` is required for high-fidelity "whodata" monitoring, which tracks *who* accessed a file.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` or generate a custom one:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) with a configuration that includes the rules in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Containerized Deployment (Docker)

For environments running containerized workloads, the honeypot can be deployed as part of a Wazuh-monitored container.

### 1. Build the Honeypot Image
An example `Dockerfile` and `entrypoint.sh` are provided in the `docker-example/` directory.

```bash
docker build -t honeypot-agent -f docker-example/Dockerfile .
```

### 2. Run the Container
Mount your persistent volumes and provide the manifest password via environment variables.

```bash
docker run -d \
  --name honeypot-agent \
  -v /opt/honeypot/artifacts:/honeypot-artifacts \
  -v /var/ossec/etc:/var/ossec/etc \
  -e MANIFEST_PASSWORD="your-strong-password" \
  -e NODE_NAME="prod-web-01" \
  honeypot-agent
```

The `entrypoint.sh` script automatically generates new artifacts on startup and injects the required FIM configuration into the Wazuh agent's `ossec.conf`.

---

## Honeypot Artifact Generation

There are two ways to deploy honeypot artifacts: using the `honeypot-deployer` CLI (recommended) or using standalone deployment scripts.

### Option A: Using the CLI (Recommended)
The CLI generates unique, randomized artifacts and tracks them in an encrypted manifest for high-fidelity monitoring and on-chain correlation.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

### Option B: Standalone Scripts
For quick deployments without installing the Python package, you can use the provided shell and PowerShell scripts. These create a standard set of honeyfiles.

**Linux:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```powershell
.\deploy.ps1
```

### Manifest Security
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** It is recommended to use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

---

## Deployment Verification

1. **Verify Artifacts:** Run the health check command:
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   On a Linux agent: `cat ~/.bitcoin/wallet.dat`
   On a Windows agent: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears in the security events.
