# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect if an attacker has successfully exfiltrated your honeypot keys and is now attempting to use them.

## Overview

When you generate honeypot artifacts, a set of public addresses is also created. By adding these addresses to "watchlists" on various block explorers, you can receive alerts whenever there is any activity (balance checks, transfers, etc.) on those addresses.

## Step 1: Export Honeypot Addresses

Use the `honeypot-deployer` CLI to export all generated public addresses to a JSON file:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## Step 2: Set Up Watchlists

### Bitcoin (BTC)
- **Explorer:** [Blockchain.com](https://www.blockchain.com/explorer) or [Blockstream.info](https://blockstream.info/)
- **Setup:** Create an account and use their "Wallet Watcher" or "Address Notification" features.

### Ethereum (ETH/EVM)
- **Explorer:** [Etherscan](https://etherscan.io/)
- **Setup:** Use the "Watch List" feature under your profile. You can set up email notifications for any transaction involving your honeypot addresses.

### Solana (SOL)
- **Explorer:** [Solscan](https://solscan.io/)
- **Setup:** Use the "Watchlist" feature to track activity on Solana `id.json` addresses.

### Ripple (XRP)
- **Explorer:** [XRP Scan](https://xrpscan.com/)

## Step 3: Integrating Alerts

Most block explorers provide API access or webhooks. For a more advanced setup, you can:
1. Use a service like **Tenderly** (for EVM chains) to get real-time alerts.
2. Script a simple monitor using `web3.py` or similar libraries to poll balances.
3. Integrate explorer webhooks with your SIEM or Slack/Discord.

## Why This Matters

Attackers often import stolen keys into their own wallets (like MetaMask or Trust Wallet) to check for funds. These applications often perform balance queries across multiple chains, which can be detected via on-chain monitoring even if the attacker's initial access was not caught by host-based FIM.
