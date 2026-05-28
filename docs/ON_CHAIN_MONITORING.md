# On-Chain Monitoring Guide

This guide explains how to set up and manage on-chain monitoring for your crypto wallet honeypot addresses.

## Overview

The fourth layer of our detection strategy is On-Chain Monitoring. By watching the public addresses of your honeypots, you can detect when an attacker imports the stolen keys into a wallet and checks for balances or attempts a transaction.

## Exporting Addresses

The `honeypot-deployer` CLI provides a command to export all generated public addresses into a single JSON file:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

This file will contain a mapping of chains to addresses:
```json
{
  "btc": ["1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"],
  "eth": ["0x742d35Cc6634C0532925a3b844Bc454e4438f44e"],
  "sol": ["v6S3p..."]
}
```

## Setting Up Watchlists

You should import these addresses into "Watchlist" services provided by various block explorers. These services will send you email, webhook, or Slack notifications when any activity occurs.

### Recommended Services

| Chain | Recommended Explorer | Feature |
|-------|----------------------|---------|
| **Ethereum / EVM** | [Etherscan](https://etherscan.io/) | Watchlist (up to 50 addresses for free) |
| **Bitcoin** | [Blockchain.com](https://www.blockchain.com/explorer) | Wallet Watcher / API |
| **Solana** | [Solscan](https://solscan.io/) | Account Tracking |
| **XRP** | [XRPScan](https://xrpscan.com/) | Account Monitoring |

### Automation via Webhooks

For a more integrated experience with your SOC or Wazuh SIEM, use services that support webhooks:
1. **Alchemy / Infura:** Provide "Notify" APIs for EVM chains.
2. **Tatum:** Offers a unified API for address subscriptions across multiple chains.
3. **QuickNode:** "QuickAlerts" for real-time blockchain notifications.

## Integrating with Wazuh

To bring on-chain alerts into your Wazuh dashboard:
1. Configure your webhook consumer (e.g., a small Python script or a serverless function).
2. Format the blockchain event into a JSON log.
3. Send the log to your Wazuh Manager via syslog or the Wazuh API.
4. The custom rules (ID 100530, 100532) in `wazuh/rules/honeypot_rules.xml` will match these events and trigger high-severity alerts.

## Safety Warning

**NEVER deposit real funds into these addresses.** These addresses are for detection purposes only. Any funds deposited will be accessible to anyone who finds the honeypot artifacts on your endpoints.
