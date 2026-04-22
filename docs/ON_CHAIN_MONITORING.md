# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. By watching the public addresses associated with your honeypots, you can detect when an attacker successfully imports stolen keys and interacts with the blockchain.

## 1. Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will produce a JSON file containing the addresses for all chains (BTC, ETH, SOL, etc.).

## 2. Setup Watchlists

Since the honeypot keys are non-funded, you don't need to run your own full node to monitor them. You can use free "Watchlist" services provided by major block explorers.

### Ethereum / EVM (Etherscan)
1. Create a free account on [Etherscan.io](https://etherscan.io/).
2. Go to **My Profile** -> **Watch List**.
3. Click **Add** and paste your honeypot ETH addresses.
4. Set Notification Method to **Email** or **Webhook**.
5. You will receive an alert if any transaction (including failed ones) occurs on that address.

### Bitcoin (Blockchain.com / BlockCypher)
- Use services like [BlockCypher](https://www.blockcypher.com/) or [Blockchain.com](https://www.blockchain.com/explorer) to subscribe to address notifications via their APIs or web interfaces.

### Solana (Solscan / SolanaFM)
1. Use [Solscan](https://solscan.io/) and create an account.
2. Use the **Account Monitor** feature to track your SOL addresses.

## 3. Integration with Wazuh (Advanced)

For a fully integrated experience, you can use a script to poll block explorers and send logs to Wazuh.

1. Write a small Python script that reads `honeypot-addresses.json`.
2. Use block explorer APIs (e.g., Etherscan API) to check for transaction history.
3. If a new transaction is found, log it to a file monitored by the Wazuh Agent:
   ```json
   {"integration": "blockchain", "address": "0x...", "txid": "0x...", "message": "On-chain activity detected on honeypot!"}
   ```
4. Wazuh will pick up this log and fire Rule `100530`.

## 4. Operational Security

- **Never** send real funds to these addresses.
- If you see activity, assume the endpoint where that specific wallet was deployed is fully compromised.
- Use the address-to-hostname mapping in your `manifest.json` to identify the breached machine.
