# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final stage of the detection strategy. It allows you to track when an attacker has successfully stolen a honeypot key and is using it on a live blockchain.

## Exporting Honeypot Addresses

To monitor your honeypots on-chain, you first need to export the public addresses generated during the deployment.

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file containing all public addresses associated with your deployment, categorized by blockchain (BTC, ETH, SOL, XRP, ADA).

## Setting Up Watchlists

The most effective way to monitor these addresses is by using "Watchlist" services provided by popular block explorers. These services send real-time notifications (email, webhook, Telegram) when any activity occurs on a watched address.

### 1. Ethereum & EVM Chains (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **Account** -> **Watch List**.
3. Click **Add** and paste your exported Ethereum addresses.
4. Set the notification method (e.g., "Notify on Incoming & Outgoing Txns").
5. Repeat for other EVM chains (BscScan, PolygonScan, etc.) if applicable.

### 2. Bitcoin (Mempool.space or Blockchain.com)
- Use [Mempool.space](https://mempool.space/) for real-time visualization.
- For notifications, use [Blockchain.com](https://www.blockchain.com/explorer) or specialized wallet tracking bots.

### 3. Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **My Watchlist** feature to add your Solana public keys.
3. Enable email notifications for any transaction activity.

## Integrating with Wazuh

While manual watchlists are great for immediate notification, you can also integrate on-chain events into your Wazuh dashboard for a unified security view.

1. **Webhook Integration:** Use a service like [Pipedream](https://pipedream.com/) or [Zapier](https://zapier.com/) to receive webhooks from block explorers.
2. **Forward to Wazuh:** Configure the service to forward the event data to your Wazuh Manager as a JSON log.
3. **Alerting:** The custom Wazuh rules (IDs 100530-100533) will automatically process these logs and trigger high-severity alerts.

## Why Monitor On-Chain?

- **Confirm Exfiltration:** If an agent alert fires (Layer 1-3) followed by on-chain activity (Layer 4), you have 100% confirmation that keys were successfully exfiltrated and used.
- **Attacker Attribution:** On-chain movement can often be traced to exchange deposit addresses, providing potential leads on the attacker's identity.
- **Post-Incident Forensic:** Even if the attacker manages to disable local monitoring, on-chain activity cannot be hidden from the public ledger.
