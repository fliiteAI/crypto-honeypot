# On-Chain Monitoring Guide

This guide explains how to monitor the generated honeypot addresses for activity on the blockchain. By tracking these addresses, you can detect when an attacker imports stolen keys into a wallet or attempt to move funds.

## 1. Export Honeypot Addresses

The first step is to extract the public addresses from your generated manifest. Use the `honeypot-deployer` CLI:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This command generates a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## 2. Setting Up Watchlists

Once you have the addresses, you should add them to "Watchlists" or "Address Alerts" on popular block explorers. These services will send you an email or webhook notification whenever a transaction occurs.

### Ethereum & EVM (Etherscan)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Click **Add** and paste your Ethereum honeypot address.
4. Enable **Notify on Incoming & Outgoing Txns**.
5. Repeat for other EVM chains (BSCSan, PolygonScan, etc.) if applicable.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) to monitor Bitcoin addresses.
2. Many explorers offer API-based webhooks for address monitoring.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Create an account and go to the **Watchlist** section.
3. Add your Solana honeypot addresses.

## 3. Integrating with Wazuh

For advanced monitoring, you can feed block explorer webhook alerts back into Wazuh.

1. Configure your block explorer to send webhooks to a listener script or a middleware.
2. The middleware should format the alert as a JSON log.
3. Wazuh can collect these logs and trigger high-severity alerts (Rule IDs 100530-100533).

### Example JSON Log for Wazuh
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabcd...",
  "honeypot": "true"
}
```

## 4. Security Warnings

- **Never Deposit Real Funds:** These addresses are for bait only. Any funds deposited will likely be stolen if the keys are compromised.
- **Manifest Security:** Your `manifest.json` contains the private keys. If you lose the manifest, you lose the ability to prove ownership of the honeypot addresses, though the public addresses remain valid for monitoring.
