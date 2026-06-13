# On-Chain Monitoring Guide

Layer 4 of the Crypto Wallet Honeypot detection strategy involves monitoring the generated public addresses for activity. This provides absolute confirmation of key theft, even if an attacker manages to exfiltrate the keys without triggering endpoint alerts.

## Exporting Addresses

After generating your honeypot artifacts, export the public addresses to a JSON file:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## Setting Up Watchlists

You should import these addresses into the "Watchlist" or "Alerts" feature of various block explorers.

### 1. Ethereum / EVM (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Account** -> **Watch List**.
3. Click **Add** and paste an address from your `watch-list.json`.
4. Enable **Notify on Incoming & Outgoing Txns**.
5. Repeat for other EVM chains (BSCSan, PolygonScan, etc.).

### 2. Bitcoin (Mempool.space / Blockchain.com)
1. Use services like [mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/) to track addresses.
2. Many mobile wallets (e.g., BlueWallet) support "Watch-only" wallets that will send push notifications for any activity.

### 3. Solana (Solscan / Solana Explorer)
1. Use [Solscan](https://solscan.io/) to monitor Solana addresses.
2. Set up alerts for the generated `id.json` addresses.

## Automated Monitoring (Recommended)

For large-scale deployments, it is recommended to use the `chain-monitor` service (forthcoming) or a similar tool that uses RPC nodes or Web3 APIs to monitor addresses programmatically.

### Integration with Wazuh
The `chain-monitor` service should be configured to send JSON logs to the Wazuh Manager. The custom decoders (`wazuh/decoders/honeypot_decoder.xml`) and rules (`wazuh/rules/honeypot_rules.xml`) are already designed to parse and alert on this data.

Example JSON event from `chain-monitor`:
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "tx_hash": "0xabc...",
  "timestamp": "2025-06-15T12:00:00Z"
}
```
This event will trigger **Rule ID 100530** (Level 15) in Wazuh.

## Important Security Note
**Generated honeypot keys are non-funded.** Never deposit real funds into these addresses. The purpose is to detect an attacker *attempting* to use the stolen keys (e.g., checking balances or attempting to transfer non-existent funds).
