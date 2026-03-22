# On-Chain Monitoring Guide: Crypto Wallet Honeypot

Layer 4 of the honeypot detection strategy involves monitoring the generated cryptocurrency addresses on their respective blockchains. If an attacker exfiltrates the honeypot keys and attempts to use them, this layer provides definitive proof of compromise.

## Exporting Honeypot Addresses

To monitor the honeypot addresses, you must first export them from your encrypted manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This will produce a JSON file containing all the public addresses generated during the artifact creation process, grouped by chain (e.g., BTC, ETH, SOL, XRP, ADA).

## Monitoring with Block Explorers

The easiest way to set up Layer 4 monitoring without custom software is to use the "Watchlist" or "Address Alert" features of popular block explorers.

### 1. Ethereum & EVM (Etherscan, BscScan, PolygonScan, etc.)
1. Create a free account on [Etherscan.io](https://etherscan.io/).
2. Go to the "Watch List" section.
3. Add the exported Ethereum addresses from `chain-monitor-addresses.json`.
4. Enable "Receive Email Notifications" for all transaction types (incoming, outgoing).

### 2. Solana (Solscan.io)
1. Create a free account on [Solscan.io](https://solscan.io/).
2. Use the "Personalized Account Alert" feature.
3. Add the exported Solana (`id.json`) public addresses.
4. Set up alerts for any account activity.

### 3. Bitcoin (Blockchain.com, Blockcypher)
1. Use a service like [Blockcypher's Webhook API](https://www.blockcypher.com/dev/bitcoin/#webhooks-and-sockets) or [Blockchain.com's Data API](https://www.blockchain.com/explorer/api/blockchain_api).
2. Many explorers offer address-specific RSS feeds or email alerts (e.g., BitcoinWho's Who).

---

## Integrating with Wazuh

For a more automated approach, you can use a custom script that periodically checks the balances and activity of the exported addresses and logs the results to the Wazuh Manager.

### 1. Custom Monitoring Script
A script can be configured to:
1. Read the `chain-monitor-addresses.json`.
2. Query the block explorer APIs for each address.
3. If activity is detected, log a JSON event to a file monitored by the Wazuh Manager.

**Example Log Format:**
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x123...", "activity_type": "outbound_transfer", "txid": "0xabc..."}
```

### 2. Wazuh Rule Activation
The custom rules (IDs `100530` through `100533`) already include logic to detect these JSON events and fire high-severity alerts.

```xml
<!-- Chain Monitor: any activity on honeypot address -->
<rule id="100530" level="15">
  <decoded_as>json</decoded_as>
  <field name="source">chain-monitor</field>
  <field name="event_type">honeypot_chain_activity</field>
  <description>HONEYPOT CRITICAL: On-chain activity detected on honeypot $(chain) address $(address) - ATTACKER IS USING STOLEN KEYS</description>
  <mitre>
    <id>T1657</id>
  </mitre>
  <group>honeypot,chain_activity,critical</group>
</rule>
```

---

## Best Practices
- **Do NOT fund the honeypot addresses.** The monitoring is for *detection only*. Any fund movement is an indicator of compromise (IOC), and sending real funds complicates the situation.
- **Set up alerts on multiple explorers.** For chains like Ethereum, an attacker may use a different explorer or a block explorer's API, so having multiple watchlists provides redundancy.
- **Monitor the native coin and tokens.** Ensure the watchlist alert includes ERC-20, SPL, and other token standards.
