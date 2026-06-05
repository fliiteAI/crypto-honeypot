# On-Chain Monitoring Guide

Once you have deployed your honeypot artifacts, the final layer of detection is monitoring the blockchain for any activity involving your honeypot addresses.

## Why Monitor On-Chain?

If an attacker successfully exfiltrates your honeypot keys, they will likely import them into their own wallet software to check for funds. On-chain monitoring allows you to:
1. **Confirm a successful theft** even if your host-level alerts were bypassed.
2. **Track the attacker's wallet** and potentially identify their main "sweep" addresses.
3. **Trigger high-severity alerts** in Wazuh based on external blockchain data.

---

## 1. Export Honeypot Addresses

Use the CLI to export all generated public addresses into a format suitable for import into watchlists:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watch-list.json
```

---

## 2. Setting Up Watchlists

You should add the exported addresses to various block explorer notification services.

### Bitcoin (BTC)
- **Service:** [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer).
- **Setup:** Create an account and add your BTC addresses to the "Watchlist" or "Alerts" section.

### Ethereum / EVM (ETH, BSC, Polygon)
- **Service:** [Etherscan](https://etherscan.io/) (or its variants like BscScan, PolygonScan).
- **Setup:** Use the "Watch List" feature in your Etherscan account to set up email or webhook notifications for any incoming/outgoing transactions.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/).
- **Setup:** Use the "Account Tracking" feature to receive notifications for activity on your SOL addresses.

---

## 3. Integrating with Wazuh

To feed these external alerts back into Wazuh, you can use the `chain-monitor` integration (if implemented) or a custom script that polls block explorers and writes to a log file monitored by the Wazuh agent.

### Example Log Format
The Wazuh `honeypot_rules.xml` expects JSON logs with the following fields:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc..."
}
```

This will trigger Rule **100530** (CRITICAL: On-chain activity detected).
