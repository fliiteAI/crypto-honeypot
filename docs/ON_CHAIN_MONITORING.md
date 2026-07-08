# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the most definitive way to confirm a successful compromise. By tracking the public addresses of your honeypots, you can detect when an attacker imports the stolen keys and begins to interact with the blockchain.

## Getting Honeypot Addresses

After generating your artifacts, use the `honeypot-deployer` CLI to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlist.json
```

This will produce a JSON file containing the public addresses for all generated chains (BTC, ETH, SOL, etc.).

## Setting Up Watchlists

You should add these addresses to "Watchlists" or "Alerts" on popular block explorers. Most explorers offer free accounts that allow you to receive email or webhook notifications for any activity on specific addresses.

### Ethereum & EVM Chains (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** -> **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Set the notification to **All Txns (In/Out)**.
5. Repeat for other EVM-compatible chains if necessary.

### Bitcoin (Blockchain.com, Mempool.space)
- **Blockchain.com:** Create a wallet or account and add the Bitcoin addresses as "Watch-Only".
- **Mempool.space:** Use their API or third-party monitoring tools that track specific BTC addresses.

### Solana (Solscan, SolanaFM)
1. Use [Solscan](https://solscan.io/) and create an account.
2. Go to **Account** -> **Watchlist**.
3. Add your Solana `id.json` address and enable notifications.

---

## Integrating with Wazuh

To bring these on-chain events into your Wazuh dashboard, you can use a small script (a "Chain Monitor") that polls block explorer APIs and sends JSON logs to the Wazuh Manager.

### Example Chain Monitor Logic
1. Read the exported addresses from `my-watchlist.json`.
2. Every 5-10 minutes, query the block explorer API for the balance or latest transactions of each address.
3. If activity is detected, format it as a JSON log:
   ```json
   {
     "source": "chain-monitor",
     "event_type": "honeypot_chain_activity",
     "chain": "ethereum",
     "address": "0x...",
     "activity_type": "outbound_transfer",
     "txid": "0x..."
   }
   ```
4. Send this log to Wazuh via the local agent or the Manager's syslog/API.

### Wazuh Rules for On-Chain Activity
The custom rules in `wazuh/rules/honeypot_rules.xml` (IDs 100530-100539) are pre-configured to trigger Level 15 alerts when these logs are received.
