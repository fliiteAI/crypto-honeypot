# On-Chain Monitoring Guide (Layer 4)

While the Wazuh agent detects initial access and exfiltration, Layer 4 monitoring tracks what happens to the stolen keys after they leave the environment. This provides "ground truth" that an attacker has successfully imported and is attempting to use the honeypot credentials.

## Step 1: Export Honeypot Addresses

After generating your artifacts, use the CLI to export the public addresses of all honeypot wallets:

```bash
honeypot-deployer export-addresses \
  --manifest ./artifacts/manifest.json \
  --output ./watch-list.json
```

The output file will contain a list of addresses and their respective chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

The easiest way to monitor these addresses is by using the "Watchlist" or "Address Alert" features of popular block explorers.

### Ethereum & EVM (Etherscan / Polygonscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account > Watch List**.
3. Click **Add** and paste an address from your `watch-list.json`.
4. Enable **Email Notifications** for all outgoing and incoming transactions.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use a service like [Mempool.space](https://mempool.space/) (self-hostable) or [Blockchain.com](https://blockchain.com).
2. For self-hosted solutions, you can script a check against your local node using `bitcoin-cli importaddress`.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use their notification service or API to track the exported SOL addresses.

---

## Step 3: Integrating with Wazuh

To bring these on-chain alerts back into your SIEM, you can use a small script to poll the block explorer APIs and log any activity to a file monitored by the Wazuh Agent.

### Example Polling Strategy
1. **Script:** A Python script runs every 30 minutes.
2. **API:** It queries the Etherscan API for the balance/history of the watch-list addresses.
3. **Log:** If a transaction is detected, it writes a JSON log:
   ```json
   {"level": "CRITICAL", "source": "on-chain", "address": "0x...", "tx_hash": "0x...", "msg": "Activity detected on honeypot address!"}
   ```
4. **Wazuh:** The agent's `ossec.conf` includes a `<localfile>` block to monitor this log file.

---

## Security Best Practices

- **NEVER** deposit real funds into these addresses. They are publically visible decoys.
- **Privacy:** Use a dedicated, non-identifiable email address for block explorer notifications.
- **Automation:** For large-scale deployments, use a dedicated monitoring tool like [Forta](https://forta.org/) or custom webhooks.
