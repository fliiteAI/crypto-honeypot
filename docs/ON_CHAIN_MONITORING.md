# On-Chain Monitoring Guide

On-chain monitoring is the fourth and final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully exfiltrated a private key and is attempting to use it on the live blockchain.

## Overview

Even if an attacker manages to bypass host-based detections and exfiltrate the honeypot artifacts, they cannot use the stolen keys without leaving a trace on the public ledger. By monitoring the public addresses associated with your honeypots, you gain visibility into the attacker's post-exfiltration actions.

## Step 1: Export Honeypot Addresses

The `honeypot-deployer` CLI provides a command to export all public addresses generated during a deployment into a format suitable for monitoring services.

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file containing the public addresses for all configured chains (BTC, ETH, SOL, XRP, ADA).

## Step 2: Set Up Block Explorer Watchlists

The easiest way to monitor these addresses is by using the "Watchlist" or "Address Alert" features of popular block explorers.

### Ethereum & EVM (Etherscan)
1.  Create an account on [Etherscan](https://etherscan.io/).
2.  Navigate to **My Account** > **Watch List**.
3.  Add the exported Ethereum addresses.
4.  Configure email notifications for any "Incoming & Outgoing" transactions.

### Bitcoin (Blockchain.com / BlockCypher)
1.  Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/).
2.  Most explorers offer API-based webhooks or email alerts for specific addresses.

### Solana (Solscan / Solana Explorer)
1.  Visit [Solscan](https://solscan.io/).
2.  Use the "Track" or "Alert" features (often requiring a free account) to monitor your Solana `id.json` addresses.

## Step 3: Advanced Monitoring (Webhooks)

For automated response, you can use webhook services that trigger a notification to your SIEM or incident response platform when activity is detected.

### Recommended Services
-   **Tatum:** Provides a unified API for address subscriptions across multiple chains.
-   **Alchemy / Infura:** Offer "Notify" services for Ethereum and Polygon.
-   **QuickNode:** Provides real-time streams and webhooks for Solana and other chains.

## Step 4: Interpreting Alerts

An alert from an on-chain monitor is a **critical severity event**.

-   **Balance Query:** Some attackers use automated scripts to check the balance of stolen keys immediately after exfiltration. While not always visible on-chain, some "dust" transactions might be sent to "active" the account.
-   **Incoming Transaction:** If you see a small amount of "gas" money being sent to a honeypot address, it's a sign that the attacker is preparing to move funds *out* (even though there are none).
-   **Outgoing Transaction:** This indicates the attacker has successfully imported the key and is attempting to transfer funds.

## Security Warning

**NEVER deposit real funds into honeypot addresses.** The purpose of these addresses is to remain empty. Any activity on these addresses is proof of compromise.
