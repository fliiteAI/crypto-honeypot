# On-Chain Monitoring Guide

On-chain monitoring is the "Layer 4" of our detection strategy. It allows us to detect when an attacker has successfully exfiltrated honeypot keys and is attempting to use them, even if they have already left the compromised network.

## Concept

Since the honeypot generates real (though unfunded) cryptocurrency addresses, we can monitor the public blockchains for any activity associated with these addresses. Legitimate users will never use these addresses, so any activity (inbound/outbound transfers, balance checks on certain platforms) is a definitive indicator of compromise.

## Step 1: Export Honeypot Addresses

After generating your honeypot artifacts, use the `honeypot-deployer` CLI to export the public addresses.

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/my-artifacts/manifest.json \
  --output ./honeypot-watch-list.json
```

This will create a JSON file containing all the public addresses generated for your deployment, categorized by chain (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

Most major block explorers provide a "Watchlist" or "Address Alert" service that can send notifications (Email, Webhook, Telegram) when activity occurs on a specific address.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1.  Create an account on [Etherscan](https://etherscan.io/).
2.  Navigate to **My Profile** > **Watch List**.
3.  Click **Add** and paste an ETH address from your export.
4.  Enable "Notify on Incoming & Outgoing Txns".
5.  Repeat for other EVM-compatible addresses.

### Bitcoin (Blockchain.com, Blockstream.info)
1.  Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
2.  Many explorers allow you to "Follow" an address if you have an account.

### Solana (Solscan)
1.  Go to [Solscan](https://solscan.io/).
2.  Log in and go to your **Watchlist**.
3.  Add your Solana addresses and configure alert settings.

## Step 3: Integrating with Wazuh (Advanced)

For a fully integrated security operations workflow, you can feed these on-chain alerts back into Wazuh.

1.  **Webhooks:** Configure the block explorer to send a Webhook to a middleware service (like a simple Python Flask app or a serverless function).
2.  **Syslog/Localfile:** Have the middleware write the alert to a log file on the Wazuh Manager.
3.  **Wazuh Decoder:** The Wazuh Manager decodes these logs using the custom honeypot decoders.
4.  **Alert:** Wazuh fires a high-severity alert (Rule ID 100530+), correlating the on-chain activity with the original endpoint compromise.

## Security Warning

**NEVER deposit real funds into honeypot addresses.** These keys are stored in a manifest and deployed as decoys; they should be considered compromised the moment they are deployed. The goal is to detect the attacker, not to provide them with actual assets.
