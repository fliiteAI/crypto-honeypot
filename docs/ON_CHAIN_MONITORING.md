# On-Chain Monitoring Guide

On-chain monitoring is the final layer of our detection strategy. It allows you to detect when an attacker successfully exfiltrates a honeypot private key and attempts to use it on the blockchain.

## Overview

Even if an attacker manages to bypass host-based detections (FIM, Audit logs), their activity on the blockchain is public and immutable. By monitoring the public addresses associated with your honeypots, you can receive alerts when:
1. An attacker imports the key into a wallet (often triggers a balance query).
2. An attacker attempts to transfer funds out of the address.
3. An attacker interacts with a smart contract using the honeypot key.

## Setup Instructions

### 1. Export Honeypot Addresses
Use the `honeypot-deployer` CLI to export all generated public addresses from your manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlists.json
```

This will create a JSON file containing addresses grouped by chain (BTC, ETH, SOL, etc.).

### 2. Configure Watchlists

Import the exported addresses into various blockchain monitoring services.

#### Ethereum & EVM (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Add your honeypot ETH addresses.
4. Enable "Email Notifications" for any incoming or outgoing transactions.

#### Solana (Solscan / Solfare)
1. Use [Solscan](https://solscan.io/) or similar explorers to track SOL addresses.
2. Many Solana wallet providers (like Solflare) offer notification services for tracked addresses.

#### Bitcoin (Blockchain.com / BlockCypher)
1. Use [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) to set up webhooks or email alerts for BTC `wallet.dat` addresses.

### 3. Automated Monitoring (Advanced)
For large-scale deployments, you can use the exported `my-watchlists.json` to feed a custom monitoring script that uses blockchain APIs (like Infura, Alchemy, or Helius) to poll for activity.

---

## Security Best Practices
- **NEVER deposit real funds** into honeypot addresses. They are designed to be bait and are considered compromised the moment they are generated.
- **Rotate Honeypots:** Periodically generate new artifacts and update your watchlists to keep the bait fresh.
- **Monitor the Monitor:** Ensure your notification channels (email, Slack, etc.) are functioning correctly to avoid missing critical on-chain alerts.
