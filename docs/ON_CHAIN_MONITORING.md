# On-Chain Monitoring Guide

Layer 4 of the Crypto Wallet Honeypot detection strategy involves monitoring the blockchain for any activity related to the generated honeypot addresses.

## Concept

When an attacker steals a honeypot private key or seed phrase, their next step is typically to import it into a wallet and check for funds or attempt a transfer. By placing these addresses on "watchlists" provided by block explorers, you can receive real-time notifications of this activity, even if the attacker has already exfiltrated the data from your network.

## Setting Up Watchlists

### 1. Export Honeypot Addresses
Use the `honeypot-deployer` CLI to export all generated public addresses to a JSON file:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-addresses.json
```

### 2. Register on Block Explorers
Create accounts on the following major block explorers and add your exported addresses to their respective watchlist/address alert features:

- **Ethereum (and EVM chains):** [Etherscan](https://etherscan.io/)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **XRP:** [Bithomp](https://bithomp.com/)

### 3. Configure Alerts
Set up the alerts to notify you via:
- **Email:** For standard monitoring.
- **Webhooks:** To integrate with your SOC or Wazuh (via a custom integration).

## Why Monitor Non-Funded Wallets?

Even though the honeypot wallets are empty, an attacker's attempt to "dust" the wallet (sending a tiny amount of crypto to pay for gas) or simply querying the balance from a known malicious IP provides invaluable intelligence:
- **Attacker's Origin:** The IP address used to query the blockchain.
- **Attacker's Wallet:** The destination address used if they attempt a transfer.
- **Confirmation of Breach:** Definitive proof that the honeypot files were not only accessed but successfully decrypted and used.

## Integration with Wazuh

For advanced users, you can use the Wazuh `integratord` to ingest webhooks from block explorers, allowing Layer 4 alerts to appear directly in your Wazuh dashboard alongside host-based alerts.
