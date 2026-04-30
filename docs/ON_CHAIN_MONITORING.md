# On-Chain Monitoring Guide

On-chain monitoring is Layer 4 of our detection strategy. It allows you to detect when an attacker has successfully exfiltrated a honeypot private key and is attempting to use it on the blockchain.

## Overview

When you generate honeypot artifacts using the `honeypot-deployer` CLI, a set of public addresses is created. By monitoring these addresses on their respective blockchains, you can receive alerts even if the initial file access (Layer 1-3) was missed or bypassed.

## Step 1: Export Honeypot Addresses

First, export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file containing all addresses generated for your deployment, categorized by chain.

## Step 2: Setup Watchlists

You should add these addresses to "Watchlists" or "Address Trackers" on major block explorers. Most explorers offer free tiers that support email or webhook alerts.

### Ethereum (and EVM Chains)
- **Service:** [Etherscan](https://etherscan.io/)
- **Setup:** Create an account -> My Profile -> Watch List -> Add New Address.
- **Notification:** Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Many explorers allow you to "Follow" an address.

### Solana
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Create an account -> My Account -> Watchlist -> Add Address.

---

## Step 3: Feeding Alerts back to Wazuh

To centralize your alerts, you should feed the on-chain activity notifications back into Wazuh.

### Method A: Email-to-Log (Simple)
If you receive email alerts from block explorers, you can configure a script to parse these emails and write a log entry to a file monitored by the Wazuh agent.

### Method B: Webhooks (Advanced)
Many block explorers support webhooks. You can set up a simple web listener (e.g., a Python Flask app or a serverless function) that receives the webhook and forwards the event to the Wazuh Manager's API or writes it to a local log file.

#### Expected Log Format
Wazuh expects a JSON log format for Layer 4 rules:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "balance_query",
  "txid": "0xabc...",
  "description": "Attacker checked balance on Etherscan"
}
```

## Relevant Wazuh Rules

The following rules in `wazuh/rules/honeypot_rules.xml` are triggered by on-chain activity:

| Rule ID | Level | Description |
|---------|-------|-------------|
| 100530 | 15 | Any activity on honeypot address |
| 100531 | 13 | Balance query (reconnaissance) |
| 100532 | 15 | Outbound transfer attempt (theft) |
| 100533 | 15 | Token approval (DeFi drainer) |

---

## Security Warning

**DO NOT** ever send real funds to these honeypot addresses. The private keys are stored in your deployment manifest and are considered compromised the moment they are deployed. The goal is to detect *interest* in the account, not to lose real assets.
