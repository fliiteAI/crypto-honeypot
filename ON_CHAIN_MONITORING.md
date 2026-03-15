# On-Chain Monitoring Guide

The Crypto Wallet Honeypot system includes a Layer 4 detection mechanism: **On-Chain Monitoring**. This allows you to detect when an attacker imports a stolen private key into a real wallet and performs activities like checking balances or attempting transfers.

## How It Works

1.  **Generate Addresses:** Use `honeypot-deployer generate` to create honeyfiles. Each file corresponds to a real public/private keypair.
2.  **Export Public Addresses:** Use the CLI to export only the public addresses from your manifest.
3.  **Import to Watchlists:** Import these addresses into blockchain explorer "Watchlists" or "Notifications" services.
4.  **Detect Activity:** When the attacker interacts with the address on-chain, you receive a notification, which can be correlated with the local file access alerts in Wazuh.

## Exporting Addresses

To get a list of your honeypot addresses for monitoring:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

The output will be a JSON file organized by chain:

```json
{
  "btc": ["bc1q...", "bc1q..."],
  "eth": ["0x...", "0x..."],
  "sol": ["...", "..."],
  "xrp": ["...", "..."],
  "ada": ["...", "..."]
}
```

## Monitoring Tools by Chain

### Ethereum & EVM (ETH, BSC, Polygon)
- **Etherscan / BSCScan / Polygonscan:**
  - Create a free account.
  - Go to **My Watchlist** -> **Add New Address**.
  - Enable "Notify on Incoming/Outgoing Transactions".
  - Use the Etherscan API to feed these events back into Wazuh for centralized alerting (Rule ID 100530+).

### Bitcoin (BTC)
- **Blockchain.com Explorer:** Supports address notifications.
- **Mempool.space:** Useful for tracking pending transactions and fee rates used by the attacker.

### Solana (SOL)
- **Solscan:**
  - Use the "Account Tracking" feature.
  - Supports Webhook notifications for real-time alerts.

### XRP Ledger (XRP)
- **XRPScan:** Provides comprehensive address tracking.

### Cardano (ADA)
- **Cardanoscan:** Track `.skey` associated addresses.

## Integration with Wazuh

The `honeypot_rules.xml` file includes rules (100530-100539) designed to handle events from an external "Chain Monitor" service. You can create a simple script that polls blockchain APIs for your exported addresses and sends any activity to the Wazuh Manager as a JSON log.

### Example Log Format
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x123...",
  "activity_type": "balance_query",
  "timestamp": "2025-06-15T12:00:00Z"
}
```

## Security Best Practice
**Never deposit real funds into honeypot addresses.** These keys are generated on a potentially compromised machine or stored in a manifest file. Their only purpose is to act as bait.
