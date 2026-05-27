# Deployment Guide: Crypto Wallet Honeypot

This guide provides technical requirements and configuration steps for deploying the honeypot system.

## System Requirements

### Hardware Recommendations
- **Wazuh Manager:** Raspberry Pi 4 (8GB) or Raspberry Pi 5. Use a high-endurance microSD card or a USB 3.0 SSD for better performance.
- **Wazuh Agents:** Any standard Linux or Windows endpoint.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016+.

---

## Honeypot Artifact Generation

The `honeypot-deployer` CLI generates unique, randomized artifacts and tracks them in an encrypted manifest for high-fidelity monitoring and on-chain correlation.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts (e.g., to a specific directory)
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

### Security Note: Manifest Protection
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** It is recommended to use the `--encrypt-manifest` flag (enabled by default) to protect it with a password. Never commit this file to version control.

---

## Wazuh Manager Setup

1.  **Open Ports:** Ensure ports `1514` (UDP/TCP) for agent communication and `1515` (TCP) for enrollment are open on the manager.
2.  **Custom Decoders:** Copy `wazuh/decoders/honeypot_decoder.xml` to `/var/ossec/etc/decoders/`.
3.  **Custom Rules:** Copy `wazuh/rules/honeypot_rules.xml` to `/var/ossec/etc/rules/`.
4.  **Active Response:** (Optional)
    ```bash
    cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
    chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
    chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
    ```
5.  **Restart:** `systemctl restart wazuh-manager`.

---

## Wazuh Agent Setup

### Linux Configuration (High Fidelity)
1.  **Install Auditd:** `sudo apt install auditd -y` (or `yum install audit` on RHEL).
2.  **Configure FIM:** Use `honeypot-deployer wazuh-config` to generate the `<syscheck>` block and add it to `/var/ossec/etc/ossec.conf`. Ensure `whodata="yes"` is enabled for the monitored paths.
3.  **Audit Rules:** Apply `wazuh/agent-config/honeypot-audit.rules` to `/etc/audit/rules.d/`.

### Windows Configuration
1.  **Install Sysmon:** Use a configuration that includes rules for monitoring access to the honeypot paths (see `wazuh/agent-config/honeypot-sysmon.xml`).
2.  **Configure FIM:** Add the generated configuration to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

---

## Browser Extension Path Mappings

The honeypot decoys should be placed in the following directories (where `[USER]` is the username):

### Windows
- **Chrome:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\[ID]`
- **Edge:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\[ID]`
- **Brave:** `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\[ID]`

### Linux
- **Chrome:** `~/.config/google-chrome/Default/Local Extension Settings/[ID]`
- **Brave:** `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/[ID]`
- **Firefox:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[UUID]`

---

## Containerized Deployment (Docker)

To deploy the Wazuh agent in a container while maintaining high-fidelity monitoring:

1.  **Run with Privileges:** The container must have audit control capabilities.
    ```bash
    docker run -d \
      --name wazuh-agent \
      --cap-add=AUDIT_CONTROL \
      --pid=host \
      -e WAZUH_MANAGER='192.168.1.100' \
      -e NODE_NAME='Honeypot-Node-01' \
      -v /path/to/honeypot-artifacts:/mnt/honeypot:ro \
      wazuh/wazuh-agent:latest
    ```

---

## Deployment Verification

1.  **Verify Artifacts:** Run the health check command:
    ```bash
    honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
    ```
2.  **Trigger a Test Alert:**
    - On Linux: `cat ~/.bitcoin/wallet.dat`
    - On Windows: `type %APPDATA%\Bitcoin\wallet.dat`
3.  **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears in the security events.
