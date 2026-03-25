# On-Chain Monitoring Guide: Tracking Stolen Keys

The final layer of detection for the Crypto Wallet Honeypot is on-chain monitoring. This guide explains how to track the generated honeypot addresses on-chain to detect when an attacker has successfully imported and attempted to use the stolen keys.

## Overview

When an attacker exfiltrates a honeypot wallet artifact, the next step is often to import it into a wallet and check for funds. By monitoring the generated honeypot addresses on their respective blockchains, we can detect:
- **Balance Queries:** Attacker evaluating the stolen assets.
- **Transfers:** Attempts to move funds from the honeypot addresses.
- **DeFi Activity:** Token approvals or interactions with decentralized applications.

## 1. Export Honeypot Addresses

Use the `honeypot-deployer` CLI to export the generated public addresses for all monitored chains.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This will generate a JSON file containing the public addresses for Bitcoin, Ethereum, Solana, and other supported chains.

## 2. Setting Up Watchlists

You should import these addresses into block explorer watchlists or a dedicated chain monitoring service.

### Recommended Block Explorers
- **Bitcoin (BTC):** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Ethereum (ETH):** [Etherscan](https://etherscan.io/) (Watchlist feature)
- **Solana (SOL):** [Solscan](https://solscan.io/)
- **Ripple (XRP):** [XRPScan](https://xrpscan.com/)
- **Cardano (ADA):** [Cardanoscan](https://cardanoscan.io/)

### Configuration Steps
1. Create an account on the relevant block explorer.
2. Go to the "Watchlist" or "Address Tracking" section.
3. Import the addresses from your `chain-monitor-addresses.json` file.
4. Configure email or webhook notifications for any incoming or outgoing transactions.

## 3. Integrating with Wazuh

For advanced monitoring, you can feed these on-chain alerts back into Wazuh. This allows for correlation between local honeypot access and subsequent on-chain activity.

- Use a custom script or a dedicated chain-monitor service (optional) to monitor addresses.
- When activity is detected, generate a JSON log event that Wazuh can ingest.
- Wazuh rules (e.g., ID 100530) will fire high-level alerts upon detecting these events.

---

**Warning:** Never deposit real funds into these honeypot addresses. They are designed to be bait and are inherently compromised from the moment they are generated and tracked in the manifest.
