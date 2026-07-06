# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect if an attacker has successfully exfiltrated keys and is attempting to use them on the blockchain.

## How it Works

1. **Generation:** When you run `honeypot-deployer generate`, the tool creates unique public addresses for each chain.
2. **Export:** You export these addresses into a format that can be imported into block explorer watchlists.
3. **Watching:** Block explorers (like Etherscan or Solscan) monitor the blockchain for any transaction involving these addresses.
4. **Alerting:** When activity is detected, the explorer sends an alert (via Email, Webhook, or Slack), which can be integrated back into Wazuh.

## Step 1: Export Honeypot Addresses

Use the CLI to export all generated public addresses from your manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## Step 2: Set Up Watchlists

Import the exported addresses into your preferred monitoring service for each chain.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
- Log in to [Etherscan](https://etherscan.io/).
- Go to **Account** -> **Watch List**.
- Add the ETH addresses from `watch-list.json`.
- Set notification method to "Notify on Outgoing & Incoming TXs".

### Solana (Solscan)
- Log in to [Solscan](https://solscan.io/).
- Use the **Watchlist** feature to track your SOL addresses.

### Bitcoin (Blockchain.com or BlockCypher)
- Use services like [BlockCypher](https://www.blockcypher.com/) to set up webhooks for specific BTC addresses.

## Step 3: Integrate Alerts with Wazuh

To bring these alerts back into Wazuh for a centralized view:

### Option A: Webhooks (Recommended)
If the block explorer supports webhooks:
1. Set up a simple webhook listener that logs the incoming request to a file.
2. Configure a Wazuh agent to monitor that log file.
3. The `honeypot_rules.xml` already contains rules (100530-100533) to parse these events.

### Option B: Email to Log
1. Receive block explorer alerts via email.
2. Use a script to parse the emails and write the event data to a local log file monitored by Wazuh.

## Why Monitor On-Chain?

- **Attacker Attribution:** On-chain activity often reveals the attacker's own wallet addresses (the destination of a transfer).
- **Confirmation:** Local file access might be a curious user, but an on-chain transfer attempt from a honeypot address is a 100% confirmed malicious compromise.
- **Persistence:** Even if the attacker wipes the endpoint and removes the Wazuh agent, you will still know that the keys they stole are being used.

---
**Note:** Never deposit real funds into honeypot addresses. These addresses are meant to be empty "canaries" only.
