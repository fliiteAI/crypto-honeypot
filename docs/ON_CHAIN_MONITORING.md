# On-Chain Monitoring Guide

Once you have deployed your honeypot artifacts, the next step is to monitor the generated blockchain addresses for activity. Since the honeypot keys are non-funded, any activity on these addresses (such as importing the key into a wallet or attempting a transaction) is a strong indicator of a successful exfiltration.

## 1. Exporting Honeypot Addresses

Use the `honeypot-deployer` CLI to export all generated addresses from your manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watch-list.json
```

## 2. Setting Up Watchlists

You can manually add these addresses to "Watchlists" on popular block explorers to receive email or webhook notifications.

### Ethereum & EVM Chains (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** -> **Watch List**.
3. Click **Add** and paste your ETH honeypot address.
4. Select "Notify on Incoming & Outgoing Txns".

### Bitcoin (Blockchain.com, Mempool.space)
- Use services like [Mempool.space](https://mempool.space/) (if self-hosted) or Blockchain.com's wallet watch features.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use their "Track Address" feature or API to monitor for any changes in the account's state.

## 3. Automated Monitoring (Recommended)

For more robust monitoring, use the exported `watch-list.json` with a script or a dedicated monitoring service.

### Using the Wazuh Integration
The project is designed to integrate with a chain monitoring daemon that can feed events back into Wazuh.

1. **Input:** The exported JSON file.
2. **Process:** Periodically polls block explorer APIs (e.g., Alchemy, Infura, or Etherscan).
3. **Output:** Logs events to a local file monitored by the Wazuh agent.

### Example Log Format
If an attacker imports the key and triggers a balance check, your monitor should log an event like:
```json
{"timestamp": "2025-06-16T14:20:00Z", "integration": "chain-monitor", "address": "0x123...", "chain": "ETH", "event": "balance_query", "source_ip": "attacker-ip"}
```

Wazuh Rule **100530** is pre-configured to detect these logs and fire a Level 15 alert.
