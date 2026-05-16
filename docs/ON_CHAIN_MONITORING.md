# On-Chain Monitoring Guide

On-chain monitoring is the final and most definitive layer of the Crypto Wallet Honeypot detection strategy. It allows you to track if an attacker has successfully imported your honeypot keys and is interacting with the blockchain.

## Overview

When you generate honeypot artifacts using the `honeypot-deployer` CLI, the tool also generates a corresponding public address for each private key. By importing these addresses into block explorer "watchlists," you can receive real-time notifications (email, webhook, Telegram) whenever activity occurs on those addresses.

## Step 1: Export Honeypot Addresses

Use the CLI to export all public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watch-list.json
```

This will create a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## Step 2: Set Up Block Explorer Watchlists

Navigate to the relevant block explorer for each chain and add the exported addresses to your account's watchlist.

### Ethereum & EVM Chains (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **Account** -> **Watch List**.
3. Click **Add** and paste your honeypot ETH address.
4. Set "Notification Method" to your preference (e.g., Email on both Incoming & Outgoing txns).
5. Repeat for other EVM chains (BSC, Arbitrum, Optimism) if applicable.

### Bitcoin (Blockchain.com, Mempool.space)
1. Use a service like [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer).
2. Many explorers offer "Address Watch" features via email subscription or custom dashboards.

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **Watchlist** feature to monitor your SOL addresses.

## Step 3: Monitoring for "No-Transaction" Activity

Note that some attackers might just query the balance of a stolen key without making a transaction.

- **Balance Queries:** Standard block explorers don't usually alert on simple balance lookups (GET requests to their API).
- **Advanced Monitoring:** For enterprise setups, consider using professional blockchain intelligence tools (like Chainalysis, TRM Labs, or specialized node monitoring) that can detect when an address is being "looked up" across their infrastructure.

## Step 4: Responding to On-Chain Alerts

If you receive an on-chain alert:
1. **Assume Compromise:** The attacker has successfully exfiltrated the private key from your endpoint.
2. **Identify the Source:** Cross-reference the on-chain address with your `manifest.json` to identify which endpoint and which wallet file was compromised.
3. **Check Wazuh Logs:** Search Wazuh for alerts related to that specific honeypot path to identify the process and user responsible.
4. **Initiate Incident Response:** Follow your organization's IR plan for credential theft.

## Important Safety Note

**NEVER deposit real funds into these honeypot addresses.** The private keys are considered compromised the moment they are deployed. Any funds sent to these addresses will likely be immediately stolen by the attacker or automated "sweeper" bots.
