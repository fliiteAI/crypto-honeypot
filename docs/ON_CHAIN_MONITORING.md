# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) provides a fail-safe detection mechanism by tracking activity on the public blockchain for the honeypot addresses. This allows you to detect if an attacker has successfully stolen and is attempting to use the keys, even if host-based logs are compromised.

## 1. Exporting Honeypot Addresses

First, you need to extract the public addresses from your deployment manifest.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file containing the addresses for all generated chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Watchlists

We recommend using free block explorer services to set up real-time alerts for these addresses.

### Ethereum / EVM (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **Account** -> **Watch List**.
3. Click **Add** and paste your honeypot Ethereum addresses.
4. Enable **Notify on Incoming & Outgoing Txns**.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use a service like [BlockCypher](https://www.blockcypher.com/) or [Blockchain.com](https://www.blockchain.com/explorer) to create address subscriptions.
2. Many explorers offer Webhook notifications for address activity.

### Solana (Solscan / Solana Explorer)
1. Use [Solscan](https://solscan.io/) to monitor Solana `id.json` addresses.
2. Set up alerts for any transaction activity.

## 3. Integrating with Wazuh

To bring these alerts into your Wazuh dashboard, you can use the `chain-monitor` integration.

### Option A: Webhook to Log
If your block explorer supports Webhooks, configure it to send POST requests to a simple listener on your Wazuh Manager or a log-collection server.
- The listener should log the event in a JSON format.
- Ensure the log includes `"source": "chain-monitor"` to trigger the custom Wazuh rules.

**Example Log Format:**
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc..."
}
```

### Option B: Scripted Polling
You can run a simple cron job that polls block explorer APIs for the addresses in your `monitored-addresses.json` and writes any new activity to a local log file monitored by the Wazuh agent.

## 4. Understanding Alerts

The following Wazuh rules are triggered by on-chain activity:

| Rule ID | Level | Description |
|---------|-------|-------------|
| **100530** | 15 | Any on-chain activity on a honeypot address |
| **100531** | 13 | Balance query detected (if supported by explorer) |
| **100532** | 15 | Outbound transfer (confirmed theft) |
| **100533** | 15 | Token approval (DeFi drainer attempt) |
| **100540** | 15 | **Correlation:** Host file access followed by on-chain activity |

---

**Note:** Never deposit real funds into these addresses. Any balance appearing on these addresses should be considered a "bait" deposit if you choose to fund them with small amounts of dust, but the primary purpose is to detect key usage.
