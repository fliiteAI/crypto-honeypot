# On-Chain Monitoring Guide

Once you have deployed honeypot artifacts, the final layer of defense is monitoring the blockchain for activity on the generated addresses. This guide explains how to set up watchlists and alerts.

## 1. Export Honeypot Addresses

Use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses --manifest ./honeypot-artifacts/manifest.json --output ./addresses.json
```

This will produce a JSON file containing the addresses for all chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Block Explorer Watchlists

The easiest way to monitor addresses without running your own node is using "Watchlists" on popular block explorers.

### Ethereum / EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot ETH address.
4. Set "Notification Method" to Email or Webhook.
5. Repeat for other EVM chains if you used the same address across multiple networks.

### Bitcoin (Blockchain.com, Mempool.space)
1. Use a service like [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer) to track the address.
2. Many explorers offer API webhooks or email alerts for address activity.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/).
2. Create an account and use the "Account Tracking" feature to receive notifications for any transaction involving your SOL honeypot address.

## 3. Automated Monitoring with Webhooks

For a more professional setup, use a blockchain indexing service like **Alchemy** or **QuickNode**.

1. Create an Alchemy account.
2. Use the **Notify API** to create an "Address Activity" webhook.
3. Add all your exported honeypot addresses to the webhook.
4. Point the webhook to your SOC's alert ingestion endpoint or a simple script that forwards the alert to Wazuh via the `custom-log` feature.

## 4. What to Look For

- **Inbound Small Transactions:** Attackers often send a tiny amount of native gas (dust) to the wallet to pay for transaction fees before draining it.
- **Balance Queries:** While balance queries are off-chain, many mobile wallets automatically perform them when a key is imported.
- **Outbound Transfers:** This is the definitive signal that the private key has been compromised and imported by an attacker.

## 5. Correlating with Wazuh

When an on-chain alert is received, cross-reference the timestamp with your Wazuh FIM logs to identify which endpoint and user account was the source of the leak.
