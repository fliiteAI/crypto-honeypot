# On-Chain Monitoring Guide

On-chain monitoring is the final and most definitive layer of the Crypto Wallet Honeypot system. By tracking the public addresses associated with your honeypot artifacts, you can detect when an attacker has successfully exfiltrated a private key and is attempting to use it.

## Overview

1. **Generate Artifacts:** Use the CLI to create honeypot files.
2. **Export Addresses:** Extract the public addresses for monitoring.
3. **Set Up Watchlists:** Import these addresses into blockchain explorers or monitoring services.
4. **Receive Alerts:** Get notified the moment an attacker interacts with a honeypot address on-chain.

---

## 1. Exporting Honeypot Addresses

The `honeypot-deployer` CLI provides a dedicated command to export all public addresses from a deployment manifest into a format suitable for monitoring services.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlists.json
```

This will create a JSON file containing addresses for all supported chains (BTC, ETH, SOL, XRP, ADA, etc.) found in the manifest.

---

## 2. Setting Up Watchlists

Once you have the list of addresses, you should add them to "Watchlists" or "Address Trackers" on major block explorers.

### Recommended Services

| Chain | Recommended Service | Feature Name |
|-------|---------------------|--------------|
| **Ethereum / EVM** | [Etherscan](https://etherscan.io) | Watch List |
| **Bitcoin** | [Blockchain.com](https://www.blockchain.com/explorer) | Wallet Watch |
| **Solana** | [Solscan](https://solscan.io) | Watchlist |
| **XRP** | [XRP Scan](https://xrpscan.com) | Account Alerts |
| **Multi-chain** | [DeBank](https://debank.com) | Bundles / Tracking |

### Configuration Tips
- **Enable Notifications:** Ensure you enable email, Telegram, or Webhook notifications for each address.
- **Track All Activity:** Monitor for both incoming and outgoing transactions. Even if the attacker just sends a small amount of "dust" to the address to check if it's active, you want to know.
- **Labeling:** Label the addresses in the monitoring service (e.g., `Honeypot-Endpoint-01-BTC`) so you can immediately identify the source of the leak.

---

## 3. Interpreting On-Chain Alerts

An on-chain alert is a high-severity event. It indicates that:
1. **The endpoint was compromised.**
2. **The honeypot file was discovered.**
3. **The data was successfully exfiltrated.**
4. **The attacker is technically capable** and actively working with the stolen assets.

### Incident Response Steps
1. **Identify the Source:** Use the label or manifest to find which endpoint the address was deployed on.
2. **Isolate the Endpoint:** Immediately isolate the compromised machine from the network.
3. **Review Wazuh Logs:** Look for the Level 12+ alerts on that endpoint to identify the process and user responsible for the initial access.
4. **Assume Total Compromise:** Treat the event as a confirmed data breach.
