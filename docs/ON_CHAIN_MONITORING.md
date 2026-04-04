# On-Chain Monitoring Guide: Crypto Wallet Honeypot

On-chain monitoring provides visibility into the final stage of an attack: the use of stolen keys. By tracking the honeypot's public addresses on various blockchain explorers, you can be alerted if an attacker initiates a transaction from one of your bait wallets.

## Exporting Public Addresses

The first step is to extract the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This will generate a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, XRP, etc.).

---

## Setting Up Watchlists

You can import these addresses into the "Watchlist" or "Address Alert" features of common block explorers.

### 1. Ethereum (Etherscan)
- **Feature:** [Etherscan Watchlist](https://etherscan.io/myaddress)
- **Setup:** Create an account, go to "Watch List," and add each ETH address.
- **Alerting:** Set "Email Notification" to "Notify on In-going & Out-going Txns."

### 2. Bitcoin (Blockchain.com / Blockstream)
- **Feature:** [Blockchain.com Wallet](https://www.blockchain.com/explorer)
- **Setup:** Add the BTC addresses to your explorer's watchlist to monitor for transactions.
- **Third-Party Services:** Services like [BitcoinWhosWho](https://bitcoinwhoswho.com/) can also provide alerts on specific addresses.

### 3. Solana (Solscan)
- **Feature:** [Solscan Address Alert](https://solscan.io/)
- **Setup:** Use Solscan's tracking features to monitor your SOL `id.json` public addresses.

### 4. XRP Ledger (XRPL.org)
- **Feature:** [XRPL Explorer](https://xrpscan.com/)
- **Setup:** Monitor the generated XRP account for any activity.

---

## Integrating with Wazuh

While on-chain alerts are typically external (e.g., email from Etherscan), you can integrate them back into Wazuh for centralized reporting:

1. **Custom Python Script:** Create a script that periodically queries the public APIs of block explorers for your honeypot addresses.
2. **Log to Local File:** Have the script write any detected activity to a JSON log file.
3. **Wazuh Log Collection:** Configure the Wazuh agent to monitor this log file and send alerts to the manager.

Example Log Format for Wazuh:
```json
{"timestamp": "2023-10-27T10:15:30Z", "chain": "ETH", "address": "0x123...", "event": "outbound_transfer", "value": "0.0 ETH"}
```
*(Note: Since these are honeypot addresses, any transaction value will likely be 0 unless the attacker uses them for other purposes.)*
