# On-Chain Monitoring Guide

This guide explains how to monitor the generated honeypot addresses on public blockchains to detect when an attacker attempts to use stolen credentials.

## Overview

The `honeypot-deployer` generates real cryptocurrency addresses. While these addresses contain no funds, an attacker who steals the private keys will likely import them into a wallet or check their balance on-chain. This activity can be detected by setting up "watchlists" on various block explorers.

## 1. Exporting Honeypot Addresses

Use the CLI to export a list of all public addresses generated in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-to-watch.json
```

This will produce a JSON file grouped by chain:

```json
{
  "btc": ["bc1q...", "1..."],
  "eth": ["0x..."],
  "sol": ["..."],
  "xrp": ["..."],
  "ada": ["..."]
}
```

## 2. Setting Up Watchlists

Add the exported addresses to the "Address Watchlist" or "Alerts" feature of the following services:

### Ethereum & EVM Chains (ETH, BNB, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) (and its siblings like BscScan, PolygonScan)
- **Setup:** Create an account -> My Profile -> Watch List -> Add New Address.
- **Alert Type:** Notify on Incoming & Outgoing TXs.

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Many explorers allow you to "Follow" an address or subscribe to Webhooks for activity.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Log in -> My Account -> Watchlist -> Add Address.

### XRP Ledger (XRP)
- **Service:** [Bithomp](https://bithomp.com/) or [XRPScan](https://xrpscan.com/)

---

## 3. Integrating with Wazuh

Once you receive an email or webhook alert from a block explorer, you can correlate it with your internal Wazuh alerts.

- **Rule 100530:** On-chain activity on honeypot address.
- **Rule 100532:** Outbound transfer from honeypot address (indicates the attacker sent gas to the account to move "assets").

## 4. Best Practices

- **Never Deposit Real Funds:** These are decoy addresses. Any funds deposited will be at risk if an attacker steals the keys.
- **Monitor Multiple Chains:** Infostealers often sweep for multiple types of wallets. Monitoring several chains increases the surface area for detection.
- **Use Webhooks:** If you have a custom security dashboard, use block explorer APIs/Webhooks to automatically ingest on-chain alerts into your SIEM.
