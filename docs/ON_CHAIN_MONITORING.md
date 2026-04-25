# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully stolen a private key and is attempting to use it on the blockchain.

## Overview

Even if an attacker manages to bypass all host-based monitoring (FIM, Audit, Network), they cannot hide their actions on the public blockchain. By adding the public addresses of your honeypots to a watchlist, you will receive alerts the moment those addresses are:
1. **Queried:** Someone checks the balance of the address.
2. **Imported:** The key is added to a wallet.
3. **Transacted:** Funds are sent to or from the address.

## Step 1: Export Honeypot Addresses

Use the `honeypot-deployer` CLI to export all generated public addresses into a format suitable for import into monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

Most major block explorers provide a "Watchlist" or "Address Alert" feature. We recommend setting up alerts on the following:

### Ethereum & EVM (Etherscan)
1. Go to [Etherscan.io](https://etherscan.io/) and log in.
2. Navigate to **Account -> Watch List**.
3. Click **Add** and paste your Ethereum honeypot address.
4. Enable **Notify on Incoming & Outgoing Txns**.
5. Repeat for other EVM chains (BSCSan, PolygonScan, etc.) if necessary.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use a service like [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/).
2. Many explorers offer email or webhook notifications for specific addresses.

### Solana (Solscan)
1. Go to [Solscan.io](https://solscan.io/).
2. Create an account and navigate to the **Watchlist** section.
3. Add your Solana honeypot address and enable notifications.

## Step 3: Advanced Monitoring (Webhooks)

For automated response, you can use blockchain indexing services that provide webhooks:

- **Alchemy / Infura:** Use "Notify" or "Webhooks" to get real-time JSON payloads when a honeypot address is involved in a transaction.
- **Tatum:** Provides a unified API for address subscriptions across multiple blockchains.

## Step 4: Correlate with Wazuh

When you receive an on-chain alert, cross-reference it with your Wazuh dashboard:
1. **Identify the Key:** Find which honeypot address triggered the alert.
2. **Find the Host:** Check your honeypot manifest to see which endpoint that specific address was deployed to.
3. **Analyze the Access:** Look for Level 12+ alerts in Wazuh for that endpoint to identify the time of the theft and the process responsible.

## Security Note

**Never deposit real funds into honeypot addresses.** The presence of any balance on these addresses makes them a target for "sweeper bots" and may complicate your detection efforts. The goal is to detect *access* and *intent*, not to lose money.
