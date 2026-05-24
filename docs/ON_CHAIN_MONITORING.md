# On-Chain Monitoring Guide

This guide explains how to monitor honeypot addresses on-chain to detect when an attacker imports and interacts with stolen keys.

## Overview

The `honeypot-deployer` generates valid public/private keypairs. While the accounts are unfunded, any on-chain activity (such as an attacker depositing a small amount of gas to move "funds" or simply checking the balance) provides definitive proof of compromise.

## 1. Export Public Addresses

Use the CLI to export all public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses.json
```

The output will be a JSON file containing addresses categorized by chain (BTC, ETH, SOL, etc.).

## 2. Set Up Watchlists

Import the exported addresses into block explorer watchlist services. Most major explorers offer free notifications:

### Ethereum (and EVM Chains)
- **Service:** [Etherscan Watchlist](https://etherscan.io/myaddress)
- **Setup:** Create an account, go to 'Watch List', and add your honeypot addresses. Enable email notifications for all incoming and outgoing transactions.

### Bitcoin
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space)
- **Setup:** Use their API or notification services to monitor the specific `wallet.dat` addresses.

### Solana
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Log in and add addresses to your 'Watchlist' to receive notifications.

## 3. Integration with Wazuh

While on-chain alerts typically come via email or webhook from the explorer, you can integrate them back into Wazuh for centralized alerting.

### Using Webhooks
1. Set up a simple web server to receive webhooks from the block explorer.
2. Log the webhook payload to a file.
3. Configure a Wazuh Agent to monitor that log file.
4. Wazuh rules (e.g., ID `100530`) will then trigger when a log entry is created.

## 4. Best Practices

- **Never Deposit Real Funds:** These are honeypots. Any funds you deposit may be immediately stolen.
- **Rotate Addresses:** For long-term deployments, consider re-generating and re-deploying honeypots every few months to maintain "freshness".
- **Monitor Multiple Chains:** Even if you primarily use Ethereum, deploy decoys for Bitcoin and Solana to increase the surface area for detection.
