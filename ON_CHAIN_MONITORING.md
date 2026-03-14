# On-Chain Monitoring Guide: Tracking Honeypot Addresses

While Wazuh detects local access to honeypot files, real-world attackers often exfiltrate these keys to use them on their own machines. On-chain monitoring provides a final layer of detection by alerting you when a stolen key is used on the blockchain.

## 1. Exporting Honeypot Addresses

The `honeypot-deployer` provides a command to export all generated public addresses into a format suitable for chain monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Block Explorer Alerts

The easiest way to monitor these addresses is by using "Watchlist" features on popular block explorers.

### Ethereum & EVM (Etherscan)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **More** -> **Watch List**.
3. Click **Add** and paste your exported Ethereum address.
4. Select **Notify on Incoming & Outgoing Txns**.
5. (Optional) Repeat for other EVM chains (BscScan, Polygonscan, etc.) if you deployed multiple.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use a service like [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer).
2. Most public explorers offer email alerts for specific addresses.
3. For enterprise deployments, consider using a self-hosted `bitcoind` with `zmq` notifications.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use the **Account Tracking** feature (requires login).
3. Add your exported Solana addresses to receive notifications of any activity.

## 3. Advanced Monitoring: Chain-Monitor Service

For large-scale deployments, we recommend using a dedicated monitoring script that polls for balance changes or new transactions.

### Using Web3 Webhooks (Recommended)
Services like **Alchemy**, **QuickNode**, or **Tatum** offer "Notify" or "Webhooks" services:
1. Create a "Webhook" for "Address Activity".
2. Add your exported honeypot addresses.
3. Point the webhook URL to your Wazuh Manager or a custom API that forwards logs to Wazuh.

## 4. Integrating with Wazuh

When an on-chain event occurs, you can ingest it into Wazuh to correlate with local endpoint activity.

### Example: Log Injection
If your monitoring script detects a transaction, it should log a message like:
```json
{"version": "1.0", "integration": "chain-monitor", "chain": "eth", "address": "0x123...", "event": "outbound_transfer", "txid": "0xabc..."}
```

Wazuh Rule ID `100530` through `100540` are pre-configured to handle these on-chain alerts when ingested via the Wazuh Manager's log collector.

## Security Warning
**NEVER deposit real funds into honeypot addresses.** These keys are stored in the `manifest.json` and on the monitored endpoints. They should be considered "compromised by design."
