# On-Chain Monitoring Guide

Once you have deployed honeypot artifacts, the final layer of defense is monitoring the blockchain for any activity related to the generated addresses. This guide explains how to use the exported honeypot addresses to set up watchlists and alerts.

## Exporting Honeypot Addresses

The `honeypot-deployer` CLI allows you to export all generated public addresses into a single JSON file. These are the addresses you should monitor.

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./monitored-addresses.json
```

The output file will look like this:

```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["..."],
  "xrp": ["..."],
  "ada": ["..."]
}
```

## Setting Up Watchlists

You can monitor these addresses using popular block explorers or dedicated monitoring services. Most services offer "Watchlist" or "Address Alert" features.

### Ethereum & EVM (Etherscan)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Set "Notification Method" to **Email** (or Webhook if you have an integration).
5. Ensure "Track ERC-20 Tokens" is enabled.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) to set up address alerts.
2. Many Bitcoin wallets also support "Watch-Only" modes where you can import these addresses to see transactions without having the private keys.

### Solana (Solscan / SolanaFM)
1. Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2. Set up account alerts for the generated Solana public keys.

---

## Integrating with Wazuh

For advanced users, you can feed block explorer webhooks into a custom script that logs to Wazuh.

### Example Integration Workflow
1. **Block Explorer** detects a transaction on a honeypot address.
2. **Webhook** is sent to your "Chain Monitor" service.
3. **Chain Monitor** parses the webhook and writes a log entry to `/var/log/chain-monitor.log`.
4. **Wazuh Agent** monitors the log file.
5. **Wazuh Manager** decodes the log (using `honeypot_decoder.xml`) and fires an alert (Rule ID `100530`).

### Sample Chain Monitor Log Format
Your integration should produce logs in a format that the Wazuh decoders can understand (preferably JSON):

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...5678",
  "activity_type": "outbound_transfer",
  "txid": "0xabc...def",
  "amount": "0.0",
  "timestamp": "2025-06-16T14:22:10Z"
}
```

## Security Best Practices
- **NEVER** deposit real funds into honeypot addresses. They are intended only to track attacker activity.
- Periodically check your watchlists to ensure they are still active and that notification settings haven't changed.
- Use a dedicated email address for honeypot alerts to avoid them getting lost in your main inbox.
