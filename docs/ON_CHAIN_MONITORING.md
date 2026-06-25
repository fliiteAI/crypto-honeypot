# On-Chain Monitoring Guide

On-chain monitoring is the final layer of defense (Layer 4) in the Crypto Wallet Honeypot system. It allows you to track if an attacker has successfully stolen and imported your honeypot keys.

## Overview

When you generate honeypot artifacts, the `honeypot-deployer` creates real (but empty) public/private key pairs. By monitoring the public addresses of these pairs on their respective blockchains, you can detect when an attacker:
1. **Checks the balance** of the stolen wallet.
2. **Attempts to transfer** funds (though there are none).
3. **Interacts with DeFi protocols** using the stolen identity.

## Exporting Addresses

First, export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-addresses.json
```

## Setting Up Watchlists

We recommend using third-party block explorer services for easy alerting.

### Bitcoin (BTC)
- **Service:** [Blockcypher](https://www.blockcypher.com/) or [Blockchain.com](https://www.blockchain.com/)
- **Setup:** Use their API or web interface to create "Address Watches" that send a webhook or email on any transaction.

### Ethereum & EVM (ETH, BSC, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) (Watchlist feature)
- **Setup:** Create a free account and add the exported addresses to your "Address Watch List". Enable email notifications for all incoming and outgoing transactions.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Use the Solscan "Account Tracking" feature to receive alerts via Telegram or Webhook.

### Ripple (XRP) & Cardano (ADA)
- **XRP:** [Bithomp](https://bithomp.com/) provides alerting services for XRP Ledger accounts.
- **ADA:** [Cardanoscan](https://cardanoscan.io/) can be used to track specific signing keys.

## Integrating with Wazuh

The `honeypot_rules.xml` included in this project contains rules (IDs 100530-100539) designed to ingest events from a "chain-monitor" source. If you build a custom script to poll these explorers, ensure it outputs JSON logs to a file monitored by the Wazuh agent in the following format:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x123...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc..."
}
```

This will trigger high-severity alerts in the Wazuh dashboard, correlating on-chain activity with local system events.
