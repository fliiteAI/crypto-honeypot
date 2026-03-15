# Validation Scripts

This directory contains scripts to verify your honeypot deployment.

## Usage

### Linux
```bash
chmod +x validate_honeypot.sh
./validate_honeypot.sh
```

### Windows
```powershell
.\validate_honeypot.ps1
```

These scripts will attempt to access standard honeypot file paths and simulate suspicious network activity to ensure your Wazuh rules and `auditd`/Sysmon configurations are working as expected.
