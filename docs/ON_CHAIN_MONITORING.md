# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final line of defense in the Crypto Wallet Honeypot system. It allows you to detect if an attacker has successfully exfiltrated a private key and is attempting to interact with it on the blockchain.

## Overview

Even if an attacker manages to bypass endpoint detection or clear logs, their actions on the blockchain are public and immutable. By "watching" the public addresses associated with your honeypot keys, you can receive alerts when:
1. An attacker queries the balance of a stolen wallet.
2. An attacker attempts to transfer funds (even if the wallet is empty).
3. An attacker interacts with a DeFi protocol or "drainer" contract.

## Step 1: Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest. This avoids exposing your private keys.

```bash
honeypot-deployer export-addresses \
  --manifest ./manifest.json \
  --output ./honeypot-watchlist.json
```

The output will be a JSON file containing the addresses for all generated chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

The most effective way to monitor these addresses is by using the "Watchlist" or "Alert" features of major block explorers.

### Ethereum & EVM Chains (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Select **Notify on Incoming & Outgoing Txns**.
5. (Optional) Repeat for other EVM chains (BscScan, Polygonscan, etc.) if applicable.

### Bitcoin (Blockchain.com / Blockcypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [Blockcypher](https://www.blockcypher.com/) to set up address notifications.
2. Many Bitcoin wallets and explorers offer "Watch-only" features that can send email or webhook alerts.

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Navigate to **Account** > **Watchlist**.
3. Add your honeypot Solana address (`id.json`).
4. Enable notifications for all transaction types.

## Step 3: Integrate with Wazuh (Advanced)

For a unified security dashboard, you can integrate these external alerts back into Wazuh.

### Using Webhooks
If your chosen block explorer supports Webhooks (like Etherscan's premium API or specialized services like [Alchemy](https://www.alchemy.com/)), you can point the webhook to a custom listener that logs to Wazuh.

**Wazuh Rule Match:**
The `honeypot_rules.xml` file already includes rules for `source: chain-monitor`. Ensure your integration logs follow this format:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x...",
  "activity_type": "outbound_transfer",
  "txid": "0x..."
}
```

## Recommended Watchlist Services

| Chain | Service | Type |
|-------|---------|------|
| **ETH / ERC-20** | Etherscan | Email / Webhook |
| **SOL / SPL** | Solscan | Email / Browser Alert |
| **BTC** | BlockCypher | API / Webhook |
| **Multi-Chain** | Alchemy / QuickNode | Developer API |

## Safety Warning
**NEVER deposit real funds into these honeypot addresses.** The private keys are stored in your deployment manifest and on the monitored endpoints. They are intended to be "bait" and should be considered compromised the moment they are generated.
