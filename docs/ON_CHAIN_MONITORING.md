# On-Chain Monitoring Guide

On-chain monitoring is the fourth and final layer of detection in the Crypto Wallet Honeypot system. It provides definitive proof of key theft and can track the movement of stolen "bait" credentials across different blockchains.

## Overview

When an attacker steals a honeypot private key or seed phrase, they will typically import it into their own wallet software to check for funds. By monitoring the public addresses associated with these honeypot keys, we can detect this activity in real-time.

## 1. Exporting Honeypot Addresses

The first step is to retrieve the public addresses of your deployed honeypots using the `honeypot-deployer` CLI.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlist.json
```

This command generates a JSON file containing the public addresses for all chains (BTC, ETH, SOL, etc.) included in your deployment.

## 2. Setting Up Watchlists

You can use various block explorer services to set up watchlists and receive notifications when activity occurs on these addresses.

### Ethereum and EVM Chains (Etherscan, PolyScan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **Account -> Watch List**.
3. Click **Add** and paste an Ethereum address from your exported JSON.
4. Set the notification type to **Sent & Received**.
5. Repeat for other EVM-compatible addresses.

### Bitcoin (Blockchain.com, Blockcypher)
Services like [Blockchain.com](https://www.blockchain.com/explorer) or [Blockcypher](https://www.blockcypher.com/) offer address monitoring APIs and email notification services.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) to search for your Solana honeypot addresses.
2. If you have an account, you can add them to your "Watchlist" to receive alerts.

## 3. Automated Monitoring (Advanced)

For professional SOC environments, you can integrate these addresses into a dedicated blockchain monitoring tool or use webhooks from block explorer APIs to feed alerts directly into your SIEM or incident response platform.

### Example: Etherscan API Webhook
You can use the Etherscan API to programmatically check the balance or transaction history of your honeypot addresses and trigger an alert if the balance changes or a transaction is detected.

## 4. Why On-Chain Monitoring?

- **Proof of Intent:** Unlike a file access alert (which could, in rare cases, be a curious employee), an on-chain alert proves the attacker has successfully exfiltrated and *used* the stolen keys.
- **Attacker Attribution:** On-chain activity may reveal the attacker's own wallet addresses or the exchanges they use, providing valuable intelligence for law enforcement.
- **Extended Detection:** Even if the attacker successfully bypasses your internal network monitoring (Layer 1-3), Layer 4 remains active and provides a final "tripwire" on the public blockchain.

## Important Note

**Never deposit real funds into these honeypot addresses.** The keys are stored in a manifest on your deployment machine and in plain-text (or easily decryptable) artifacts on your endpoints. They are intended solely for detection, not for holding assets.
