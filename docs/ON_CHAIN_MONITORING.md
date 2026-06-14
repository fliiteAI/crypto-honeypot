# On-Chain Monitoring Guide

Layer 4 of the Crypto Wallet Honeypot involves monitoring the public addresses of your generated honeypots for any on-chain activity. This provides definitive proof that an attacker has successfully extracted and imported your honeypot keys.

## 1. Exporting Addresses

After generating your honeypot artifacts, use the `honeypot-deployer` to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./manifest.json \
  --output ./honeypot-addresses.json
```

This command produces a JSON file containing the chain and public address for every generated honeypot.

## 2. Setting Up Watchlists

To receive alerts for on-chain activity, you should import these addresses into the "Watchlist" or "Address Tracker" features of major block explorers.

### Supported Chains & Explorers
- **Ethereum (ETH/EVM):** [Etherscan](https://etherscan.io/)
- **Bitcoin (BTC):** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana (SOL):** [Solscan](https://solscan.io/)
- **Cardano (ADA):** [Cardanoscan](https://cardanoscan.io/)
- **XRP:** [XRPScan](https://xrpscan.com/)

### How to Configure
1. Create a free account on the chosen block explorer.
2. Navigate to the "Watchlist" or "Custom Alerts" section.
3. Add the exported public addresses.
4. Configure notifications (Email, Webhook, or Telegram) to trigger when a transaction occurs.

## 3. Integrating with Wazuh

For a centralized view, you can integrate block explorer webhooks with your Wazuh Manager.

1. **Configure Webhook:** Point the block explorer's alert webhook to a custom listener on your Wazuh Manager (or a middle-ware like N8N/Zapier).
2. **Log to Wazuh:** Ensure the incoming webhook data is logged to a file monitored by the Wazuh Agent on the manager.
3. **Trigger Rules:** Custom rules in `wazuh/rules/honeypot_rules.xml` (IDs 100530-100539) are designed to match these events and fire high-severity alerts.

## 4. Establishing "Bait" (Optional)

To increase the realism of your honeypot, you can optionally fund the addresses with a very small amount of "dust" or worthless testnet tokens.

**Warning:** Never deposit significant real funds into honeypot addresses. The goal is to detect the *attempt* to move funds, not to lose actual assets.
