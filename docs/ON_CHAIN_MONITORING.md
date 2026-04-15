# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of the detection strategy. By watching the public addresses of your honeypot wallets, you can detect when an attacker successfully exfiltrates a key and attempts to use it.

## Overview

When you generate artifacts using `honeypot-deployer`, the public addresses corresponding to the private keys are stored in the `manifest.json`. You can export these addresses and import them into various blockchain monitoring services.

## 1. Export Honeypot Addresses

Use the CLI to export a list of all public addresses in a format suitable for monitoring:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will produce a JSON file containing the addresses for all chains (BTC, ETH, SOL, etc.) included in that deployment.

## 2. Setting Up Watchlists

We recommend using free or paid block explorer services to set up "Watchlists." These services will email you or trigger a webhook when activity occurs on the specified addresses.

### Ethereum & EVM (ETH, BSC, Polygon)
1. Go to [Etherscan](https://etherscan.io/) (or the relevant explorer for your chain).
2. Create an account and navigate to **My Profile > Watch List**.
3. Add the exported Ethereum addresses.
4. Enable **Notify on Incoming & Outgoing Txns**.

### Bitcoin (BTC)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
2. Many explorers allow you to "Follow" an address to receive notifications.

### Solana (SOL)
1. Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2. Create an account and add addresses to your **Watchlist**.

---

## 3. Interpreting On-Chain Activity

Since your honeypot wallets are **not funded**, any activity is significant:

- **Balance Queries:** Some automated tools query the balance of every address they steal. While not a transaction, some advanced monitoring tools can detect these queries if the attacker uses a known "leaked key" scanner.
- **Small Incoming Transactions (Dusting):** Attackers sometimes send a tiny amount of gas (e.g., 0.001 ETH) to an address before attempting to sweep it. This is a high-fidelity indicator of imminent theft.
- **Outgoing Transactions:** If you see an outgoing transaction, it means the attacker has successfully imported the key and is attempting to move funds (which shouldn't be there, unless it's a "gas" payment they sent themselves).

## 4. Automation with Webhooks

For advanced users, you can use services like **Alchemy**, **QuickNode**, or **Tenderly** to set up real-time webhooks. These can be integrated directly with your Wazuh Manager or a custom alerting platform.

### Example: Alchemy Notify
1. Create an Alchemy account.
2. Set up an **Address Activity Webhook**.
3. Provide the list of honeypot addresses.
4. Point the webhook to an endpoint that forwards the alert to Wazuh (e.g., via the Wazuh API or a custom log file).

---

## Security Warning

**NEVER deposit real funds into honeypot addresses.** The private keys are stored in the manifest and deployed on monitored endpoints; they should be considered "compromised by design."
