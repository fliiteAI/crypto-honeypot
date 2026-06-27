# Guide: On-Chain Monitoring

On-chain monitoring (Layer 4) is the final stage of the detection strategy. It allows you to track if an attacker has successfully exfiltrated your honeypot keys and is attempting to use them.

## Overview

Even if an attacker manages to bypass your endpoint security and network filters, they cannot hide their activity once they interact with the public blockchain. By monitoring the public addresses associated with your honeypots, you can confirm a successful theft and potentially trace the attacker's destination wallets.

## How to Set Up Monitoring

### 1. Export Honeypot Addresses
First, use the `honeypot-deployer` CLI to extract the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watchlist.json
```

This will create a JSON file containing the addresses for all chains generated in that deployment (BTC, ETH, SOL, etc.).

### 2. Configure Watchlists

You should add these addresses to "Address Watchlists" on popular block explorers and monitoring services. Most services offer free email or webhook alerts.

#### Ethereum / EVM (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** > **Watch List**.
3. Add your honeypot ETH addresses.
4. Set "Notification Method" to "Email on Incoming & Outgoing Txns".

#### Bitcoin (Blockchain.com, Blockcypher)
- Use services like [Blockchain.com's Wallet](https://www.blockchain.com/) (importing as "Watch-Only") or monitoring APIs like [BlockCypher](https://www.blockcypher.com/).

#### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) or [SolanaFM](https://solanafm.com/).
2. Many Solana explorers allow you to "Track" an address and receive browser or email notifications.

### 3. Integrated Monitoring (Advanced)
For automated organizations, you can feed the output of `export-addresses` into a custom script that polls the blockchain via providers like:
- **Alchemy** (Webhooks / Notify API)
- **Infura**
- **QuickNode**

## What to Look For

- **Balance Queries:** Some monitoring services can alert you when an address is searched or queried via API (e.g., Alchemy Notify).
- **Incoming Transactions:** Attackers often send a small amount of "gas" (ETH/SOL) to a stolen address to pay for the transaction fees required to move other assets. This is a primary indicator of activity.
- **Outgoing Transactions:** A definitive sign that the private key has been compromised and the attacker is attempting to drain the wallet.

## Correlating with Wazuh

When an on-chain alert is received, cross-reference the time of the transaction with your Wazuh alerts to identify which endpoint was compromised.

The Wazuh rule `100530` is designed to ingest JSON logs from a chain monitoring script to provide unified alerting within the Wazuh dashboard.
