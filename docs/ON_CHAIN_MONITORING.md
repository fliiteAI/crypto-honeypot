# On-Chain Monitoring Guide: Crypto Wallet Honeypot

This document describes how to monitor the generated honeypot addresses on the public blockchain for activity.

## Overview

The `honeypot-deployer` CLI generates non-funded cryptocurrency addresses and private keys. By monitoring these addresses on-chain, you can confirm when an attacker has successfully stolen a honeyfile and imported the key into a wallet.

### 1. Export Honeypot Addresses

After generating your honeypot artifacts, export the public addresses to a JSON file:

```bash
# Replace 'manifest.json' with your manifest's path
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./monitored-addresses.json
```

The exported JSON will look like this:

```json
{
  "btc": ["1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"],
  "eth": ["0x32Be343B94f860124dC4fEe278FDCBD38C102D88"],
  "sol": ["Hpx9fUvU67U6fS9u9TfG5b3rZ2vG8S4vS9wS5eS1eS2e"],
  "xrp": ["rDsbeomae4FXv9ipD7PjE7R5uD2pD4pD5p"],
  "ada": ["addr1q9p5r9p5r9p5r9p5r9p5r9p5r9p5r9p5r9p5r9p5"]
}
```

### 2. Set Up Block Explorer Watchlists

The easiest way to monitor these addresses is by using the "Watchlist" or "Address Alert" feature of popular block explorers.

#### Ethereum and EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** > **Watch List**.
3. Click **Add** and enter your generated ETH address.
4. Enable **Email Notifications** for both "Incoming" and "Outgoing" transactions.

#### Solana (Solscan, SolanaFM)
1. Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2. Many Solana explorers support "Address Tracking" or "Webhooks" for developers to monitor specific addresses.

#### Bitcoin (Blockchain.com, Blockcypher)
1. [Blockchain.com](https://www.blockchain.com/explorer) and [Blockcypher](https://www.blockcypher.com/) provide API endpoints and alert services for monitoring Bitcoin addresses.

### 3. Automated Monitoring (Advanced)

For a more robust solution, you can use a script to poll the blockchain for activity on your monitored addresses.

- **Etherscan API:** Use the `account.txlist` endpoint to check for recent transactions.
- **Solana Web3.js:** Use `onAccountChange` to get real-time notifications of any balance changes.
- **Blockdaemon/Alchemy:** These infrastructure providers offer powerful APIs for multi-chain monitoring.

---

## Security Best Practices

- **Never Deposit Funds:** These addresses are for monitoring only. Depositing real funds will only alert the attacker that the wallet is active and potentially valuable.
- **Monitor the Manifest:** Treat the `manifest.json` as highly sensitive, as it contains the private keys that could allow an attacker to claim any funds deposited (by mistake or by the attacker themselves).
- **Use Encrypted Manifests:** Always generate your manifest with a strong password to protect the private keys at rest.
