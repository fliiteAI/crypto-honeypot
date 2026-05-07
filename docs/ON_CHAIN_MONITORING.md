# On-Chain Monitoring Guide

On-chain monitoring is the final and most definitive layer of the Crypto Wallet Honeypot detection strategy. It allows you to track if an attacker has successfully stolen a private key and is attempting to use it.

## Why Monitor On-Chain?

- **Zero False Positives:** No legitimate user should ever have the private key to a honeypot address. Any transaction is a confirmed attack.
- **Persistence:** Even if an attacker wipes the logs on the compromised host, the blockchain provides an immutable record of their theft.
- **Intelligence:** You can see where the attacker sends the funds, potentially identifying their exchange accounts or other infrastructure.

## Step 1: Export Honeypot Addresses

Use the `honeypot-deployer` CLI to export all public addresses generated during deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/manifest.json \
  --output ./my-watch-addresses.json
```

This will create a JSON file containing the public addresses for all chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

The easiest way to monitor addresses without running your own node is to use block explorer "Watchlist" services.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** -> **Watch List**.
3. Add your honeypot ETH addresses.
4. Set "Notify on" to **All Transactions (Incoming & Outgoing)**.
5. Choose **Email Notification**.

### Bitcoin (Blockchain.com, Blockcypher)
1. Use a service like [BlockCypher](https://www.blockcypher.com/) or [Blockchain.com](https://www.blockchain.com/explorer) that supports address notifications via Webhooks or Email.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2. Many Solana explorers offer notification services or "Account Tracking" features.

## Step 3: Integrate with Wazuh (Advanced)

If you want these alerts to appear in your Wazuh dashboard, you can use a script to poll block explorer APIs and send the results to the Wazuh Manager as a local file or via the `ossec-logcollector`.

### Example Log Format
The Wazuh `honeypot_rules.xml` expects on-chain logs in the following JSON format:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "activity_type": "outbound_transfer",
  "chain": "ethereum",
  "address": "0x123abc...",
  "txid": "0xdef456...",
  "amount": "0.0"
}
```

## Security Best Practices

1. **NEVER deposit real funds:** Honeypot addresses are for detection only. Depositing funds makes them a target for real theft and provides no additional security value.
2. **Rotate Addresses:** If a honeypot address is triggered, consider it burned. Generate new artifacts and update your watchlists.
3. **Monitor Multiple Chains:** Infostealers often grab everything. Monitoring Solana and Bitcoin addresses may catch an attacker even if they don't use the Ethereum keys.
