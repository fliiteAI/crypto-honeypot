# Guide: On-Chain Monitoring

On-chain monitoring is the final and most definitive layer of detection in the Crypto Wallet Honeypot system. It allows you to track when an attacker actually imports and uses the stolen credentials on a live blockchain.

## Why Monitor On-Chain?
While Wazuh detects the *theft* of the wallet files, on-chain monitoring detects the *utilization* of those stolen assets. This confirms that the attacker has successfully exfiltrated the data and is attempting to monetize it.

## 1. Export Honeypot Addresses
After generating your honeypot artifacts, use the CLI to export the public addresses of all generated wallets:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watch-list.json
```

This will produce a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## 2. Set Up Block Explorer Watchlists
Most major block explorers provide "Watchlist" or "Address Alert" features. You should add your exported honeypot addresses to these services.

### Ethereum & EVM (Etherscan, Polygonscan, BSCScan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** > **Watch List**.
3. Click **Add** and paste your honeypot ETH address.
4. Enable **Notify on Incoming & Outgoing Txns**.

### Bitcoin (Blockchain.com, Blockstream.info)
- Use services like [BitcoinWhosWho](https://bitcoinwhoswho.com/) or similar alerting tools that support BTC address monitoring.

### Solana (Solscan)
1. Log in to [Solscan](https://solscan.io/).
2. Use the **My Watchlist** feature to track your SOL addresses.

## 3. Automated Monitoring (Advanced)
For enterprise deployments, you may want to automate this monitoring using blockchain indexers or APIs:

- **Alchemy/Infura Webhooks:** Set up "Notify" webhooks to receive real-time POST requests when activity occurs on an address.
- **Tenderly:** Use Tenderly Alerts for advanced monitoring of EVM addresses, including internal transactions.

## 4. Responding to On-Chain Alerts
If you receive an alert from a block explorer:
1. **Correlate:** Check your Wazuh dashboard for recent FIM or Process Auditing alerts that match the time of the on-chain activity.
2. **Identify Source:** Use the Wazuh telemetry to identify which endpoint was compromised.
3. **Isolate:** Immediately isolate the affected endpoint to prevent further data loss or lateral movement.
