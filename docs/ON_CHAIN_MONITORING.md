# On-Chain Monitoring Guide

Layer 4 of our detection strategy involves monitoring the public addresses of generated honeypots for any activity. This ensures that even if an attacker successfully exfiltrates the keys and evades host-based detection, their subsequent actions are still tracked.

## 1. Exporting Honeypot Addresses

After generating your artifacts, you can export the public addresses into a format suitable for import into block explorer watchlists or automated monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## 2. Using Block Explorer Watchlists

The easiest way to monitor addresses for small deployments is to use the "Watchlist" or "Address Alert" features provided by major block explorers.

### Ethereum / EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io).
2. Navigate to **My Profile** -> **Watch List**.
3. Add the exported Ethereum addresses.
4. Enable "Notify on Incoming & Outgoing Txns".

### Solana (Solscan)
1. Use [Solscan](https://solscan.io) to track Solana `id.json` addresses.
2. Set up alerts via their monitoring tools or API if available.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use [Mempool.space](https://mempool.space) to monitor the status of Bitcoin honeypot addresses.

---

## 3. Automated Monitoring (Chain Monitor)

For enterprise deployments, you should integrate these addresses into your SOC's existing monitoring pipeline.

### Custom Integration
The `honeypot_rules.xml` (Rule 100530) is designed to ingest JSON logs from a "Chain Monitor" service. A simple script can poll block explorer APIs and write logs to a file monitored by the Wazuh Agent:

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

### Security Warning
**Never deposit real funds into these addresses.** The purpose is to detect the *attacker* attempting to use the stolen keys, which usually begins with a balance query (detected via RPC logs if you run your own node) or a small test transaction if the attacker adds gas to the account.
