# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final stage of detection. It confirms when an attacker has successfully exfiltrated a private key and is attempting to use it on the blockchain.

## Exporting Honeypot Addresses

First, export the public addresses of your deployed honeypots:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watch-list.json
```

## Setting Up Watchlists

You should add these addresses to monitoring services to receive real-time alerts.

### 1. Block Explorer Watchlists
- **Ethereum/EVM:** Use [Etherscan's Watchlist](https://etherscan.io/myaddress) feature.
- **Bitcoin:** Use [Blockchain.com Explorer](https://www.blockchain.com/explorer) or similar.
- **Solana:** Use [Solscan](https://solscan.io/) or [Solana.fm](https://solana.fm/).

### 2. Specialized Monitoring Tools
- **Tenderly:** Great for monitoring EVM transactions with detailed execution traces.
- **Burner Bots:** If you want to automatically move funds (if any were accidentally deposited), you can set up a burner bot, though this is not recommended for honeypots.

## Integrating with Wazuh

Once you receive an alert from an external monitoring service, you can ingest these events into Wazuh for centralized alerting.

### Custom Log Ingestion
If you use a custom script to monitor the chain, have it write logs to a file that the Wazuh agent monitors:

```json
{"event": "on_chain_activity", "address": "0x123...", "chain": "ethereum", "txid": "0xabc..."}
```

Wazuh Rule 100530 is designed to pick up these events:

```xml
<rule id="100530" level="15">
  <decoded_as>json</decoded_as>
  <field name="event">on_chain_activity</field>
  <description>On-chain activity detected on honeypot address $(address)</description>
  <group>crypto_honeypot,on_chain_activity,</group>
</rule>
```

## Why Monitor On-Chain?

1. **Confirmation of Breach:** File access might be a curious user, but on-chain activity is definitive proof of malicious intent and successful exfiltration.
2. **Attacker Attribution:** Attacker wallet addresses used in transactions can be used for further threat intelligence gathering.
3. **Recovery:** While honeypots shouldn't have funds, monitoring ensures you know the exact moment your "secrets" were used.
