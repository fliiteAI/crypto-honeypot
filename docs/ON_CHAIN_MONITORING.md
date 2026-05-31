# On-Chain Monitoring Guide

On-chain monitoring is the fourth and final layer of the Crypto Wallet Honeypot detection strategy. It provides absolute confirmation of a compromise by detecting when an attacker imports and uses stolen private keys.

## Overview

When you generate honeypot artifacts using the CLI, the system creates unique public/private key pairs. By importing the public addresses of these honeypots into block explorer watchlists, you receive alerts the moment an attacker interacts with them on the blockchain.

## Step 1: Export Honeypot Addresses

After generating your artifacts, use the `export-addresses` command to create a list of all public addresses in a format suitable for monitoring.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watch-list.json
```

This will generate a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## Step 2: Set Up Block Explorer Watchlists

Most major block explorers provide free "Watchlist" or "Address Alert" services.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** -> **Watch List**.
3. Add your honeypot ETH addresses.
4. Set notification settings to "Email on all Outgoing & Incoming Txns".

### Bitcoin (Blockchain.com, Blockcypher)
1. Use services like [Blockchain.com's Wallet](https://www.blockchain.com/) or [Blockcypher](https://www.blockcypher.com/) to monitor addresses.
2. Many explorers support Webhooks for real-time notifications.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) and its account tracking features.
2. Set alerts for any transaction activity.

## Step 3: Integrating with Wazuh (Optional)

For more advanced setups, you can feed these on-chain alerts back into Wazuh.

1. **Webhook Integration:** Use a custom script to receive webhooks from block explorers.
2. **Log Ingestion:** Have the script write these events to a log file monitored by the Wazuh Agent.
3. **Alert Triggering:** Wazuh will match these against rules `100530` through `100533` in `honeypot_rules.xml`.

## Why On-Chain Monitoring?

- **Zero Host Visibility Needed:** Even if an attacker wipes the host or exfiltrates the keys to an offline machine, their activity on the chain remains visible.
- **Confirmation of Intent:** A file access might be a mistake, but importing a key and querying its balance is a clear indicator of malicious intent.
- **Theft Detection:** It allows you to see if the attacker is attempting to move funds or interact with DeFi protocols.

## Security Warning

**NEVER deposit real funds into these honeypot addresses.** The private keys are stored in your `manifest.json` and on the monitored endpoints. They are intended to be bait, not functional wallets.
