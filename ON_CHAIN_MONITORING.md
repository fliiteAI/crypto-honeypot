# On-Chain Monitoring Guide: Tracking Bait Addresses

This guide explains how to monitor the generated honeypot addresses for activity on block explorers and other external tools.

## 1. Export Honeypot Addresses

The first step is to retrieve the public addresses of the generated honeypots. Use the `export-addresses` CLI command:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./bait-addresses.json
```

The output file will contain a JSON list of public addresses organized by chain (BTC, ETH, SOL, XRP, ADA).

## 2. Set Up Block Explorer Watchlists

Most popular block explorers offer "Watchlist" or "Address Alert" features that notify you (via email, Telegram, or Webhook) when an address receives or sends funds.

### Ethereum and EVM Chains (Etherscan, BscScan, Polygonscan)
1. Create an account on [Etherscan](https://etherscan.io).
2. Go to **My Profile** > **Watch List**.
3. Click **Add** and paste an address from your `bait-addresses.json`.
4. Enable **Notify on Incoming & Outgoing Txns**.
5. Repeat for each address.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io).
2. Search for a bait address.
3. Click the **Notification** (bell) icon to set up alerts (requires an account).

### Bitcoin (Blockchain.com Explorer)
1. Use an explorer that supports address-based notifications or use a dedicated monitoring service like [BlockCypher](https://www.blockcypher.com/) to set up webhooks for specific BTC addresses.

## 3. Advanced Monitoring with Webhooks

For a more automated response, you can use specialized blockchain monitoring services that trigger webhooks.

- **Alchemy / Infura:** Use their "Notify" or "Address Activity" APIs to receive real-time JSON payloads when a bait address is queried or involved in a transaction.
- **Tenderly:** Provides sophisticated alerting and simulation for EVM-based bait addresses.

## 4. Why On-Chain Monitoring?

- **Detection Beyond the Host:** Even if an attacker successfully exfiltrates a wallet and moves to another machine, their interaction with the blockchain will be detected.
- **Attacker Intent:** Monitoring for queries (using services like Alchemy) can indicate that an attacker is checking balances, which confirms active interest in the stolen credentials.
- **Asset Recovery:** In the event that a honeypot was accidentally funded (not recommended), on-chain monitoring is the first step toward tracking the attacker's movement of those funds.
