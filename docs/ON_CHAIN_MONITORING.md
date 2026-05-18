# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect when an attacker has successfully exfiltrated your honeypot keys and is attempting to use them, even if the initial theft occurred on an unmonitored system or went undetected by the agent.

## How It Works

1. **Generate Artifacts:** Use the `honeypot-deployer generate` command to create your honeypots.
2. **Export Addresses:** Export the public addresses associated with those honeypots.
3. **Setup Watchlists:** Import these addresses into a block explorer's watchlist service.
4. **Receive Alerts:** Get notified via email, webhook, or Telegram when activity occurs on those addresses.

## Exporting Addresses

Use the CLI to generate a list of public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watchlist.json
```

The output file will contain the public addresses for all generated chains (BTC, ETH, SOL, etc.).

## Setting Up Watchlists

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** -> **Watch List**.
3. Click **Add** and paste your generated Ethereum address.
4. Set notification settings to "All Transactions (Incoming & Outgoing)".

### Bitcoin (Blockchain.com, Mempool.space)
1. Most major explorers offer "Address Watch" services via email.
2. For professional monitoring, consider using a service like [Blockcypher](https://www.blockcypher.com/dev/bitcoin/#confidence-factor) webhooks.

### Solana (Solscan)
1. Log in to [Solscan](https://solscan.io/).
2. Use the **Watchlist** feature to track your SOL addresses.
3. Solscan supports Telegram notifications for watchlist hits.

## Responding to On-Chain Alerts

An on-chain alert is a **100% confidence indicator** of a compromise. If you see activity on a honeypot address:
1. **Identify the Source:** Use the `manifest.json` to determine which host the specific address was deployed to.
2. **Isolate the Host:** Immediately disconnect the affected machine from the network.
3. **Initiate Incident Response:** Assume all other credentials on that host are compromised.
