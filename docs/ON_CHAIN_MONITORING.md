# On-Chain Monitoring Guide

On-chain monitoring is the final layer (Layer 4) of our detection strategy. It allows you to detect when an attacker has successfully exfiltrated honeypot keys and is attempting to use them on a live blockchain.

## How It Works

1.  **Generate Artifacts:** Use the `honeypot-deployer` to generate honeypot wallets. This process creates a public address and a private key for each wallet.
2.  **Export Addresses:** Use the CLI to export the public addresses of your honeypots.
3.  **Setup Watchlists:** Import these addresses into various block explorer "watchlists" or "address trackers."
4.  **Receive Alerts:** When an attacker queries the balance or attempts a transaction with one of these addresses, the block explorer will send you a notification.

---

## Exporting Honeypot Addresses

To get a list of all public addresses from your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-addresses.json
```

---

## Setting Up Watchlists

We recommend setting up watchlists on the following platforms for maximum coverage:

### Ethereum & EVM Chains (ETH, BSC, Polygon, etc.)
- **Etherscan:** [etherscan.io](https://etherscan.io/)
- **Instructions:**
  1. Create a free account.
  2. Go to **My Profile** > **Watch List**.
  3. Click **Add** and paste your honeypot Ethereum address.
  4. Enable "Notify on Incoming & Outgoing Txns."

### Bitcoin (BTC)
- **Blockchain.com Explorer:** [blockchain.com/explorer](https://www.blockchain.com/explorer)
- **Mempool.space:** [mempool.space](https://mempool.space/) (supports email alerts for specific addresses).

### Solana (SOL)
- **Solscan:** [solscan.io](https://solscan.io/)
- **Instructions:**
  1. Create an account.
  2. Use the "Track Address" feature to add your Solana honeypot address.

### Ripple (XRP)
- **XRPScan:** [xrpscan.com](https://xrpscan.com/)

---

## Integrating with Wazuh

While block explorers provide email notifications, you can integrate these alerts into Wazuh for a centralized view:

1.  **Webhooks:** If the block explorer supports webhooks, you can point them to a custom listener that logs to a file monitored by Wazuh.
2.  **Custom Script (Chain Monitor):** You can write a small script that periodically queries the balance of your honeypot addresses via an API (like Infura or Alchemy) and logs any activity in JSON format.
3.  **Wazuh Rules:** Our system includes rules (IDs 100530-100533) designed to process logs from a "chain-monitor" source.

Example log format for `chain-monitor`:
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "ethereum", "address": "0x...", "activity_type": "outbound_transfer"}
```

---

## Security Note

**Never deposit real funds into honeypot addresses.** These addresses are for detection purposes only. Any activity on these addresses should be treated as a confirmed security breach of the endpoint where the artifact was deployed.
