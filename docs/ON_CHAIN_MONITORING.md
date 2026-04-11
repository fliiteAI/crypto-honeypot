# On-Chain Monitoring Guide: Crypto Wallet Honeypot

This document provides a comprehensive guide for establishing and tracking real bait addresses on Bitcoin, Ethereum, Solana, and other chains to monitor for stolen credentials.

## Introduction

The honeypot system generates real cryptocurrency addresses with associated private keys stored in a deployment manifest. By monitoring these addresses on-chain, you can detect when an attacker imports the keys into a wallet or queries their balance — a high-fidelity indicator of a successful breach.

## Step 1: Export Honeypot Addresses

The `honeypot-deployer` CLI allows you to export all public addresses generated during deployment.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

The output file will contain a list of addresses categorized by blockchain:
```json
{
  "bitcoin": ["bc1q...", "bc1q..."],
  "ethereum": ["0x...", "0x..."],
  "solana": ["Abc...", "Xyz..."]
}
```

## Step 2: Establish Watchlists

Add the exported addresses to watchlists on popular block explorers or monitoring services.

### Recommended Services

| Chain | Service | Feature |
|-------|---------|---------|
| **Ethereum / EVM** | [Etherscan](https://etherscan.io/) | Watchlist with email/webhook alerts |
| **Bitcoin** | [Blockchain.com](https://www.blockchain.com/explorer) | Watchlist alerts |
| **Solana** | [Solscan](https://solscan.io/) | Account tracking and alerts |
| **Multi-chain** | [DeBank](https://debank.com/) | Portfolio monitoring (visual) |

### Setup Instructions (Etherscan Example)
1. Create a free account on [Etherscan.io](https://etherscan.io/).
2. Navigate to **My Profile** -> **Watch List**.
3. Click **Add** and paste an Ethereum address from your exported list.
4. Set **Notification Method** to "Email Notification on incoming & outgoing txns".
5. (Optional) Provide a descriptive name like "Honeypot-Endpoint-01-ETH".

## Step 3: Advanced Monitoring (Webhooks)

For enterprise SOC environments, it is recommended to use webhook-based alerts that feed directly into your SIEM or incident response platform.

### Using Alchemy or QuickNode
Services like Alchemy and QuickNode provide "Notify" or "Webhook" APIs that trigger a POST request to your specified endpoint whenever activity is detected on a watched address.

1. **Create an Alchemy account.**
2. **Setup a Notify Webhook:**
   - Choose "Address Activity".
   - Select the network (e.g., Ethereum Mainnet).
   - Paste the honeypot addresses.
   - Provide your SOC webhook URL.

## Step 4: Incident Response

If an on-chain alert is triggered:
1. **Identify the Source:** Match the triggered address against your `manifest.json` to find the specific endpoint and user profile where the artifact was deployed.
2. **Correlate with Wazuh:** Check the Wazuh dashboard for recent FIM or process audit alerts from that endpoint.
3. **Assume Compromise:** An on-chain alert means the attacker has likely successfully exfiltrated the keys and is actively attempting to use them.

## Important Security Notes

- **Never Deposit Real Funds:** These addresses are for bait only. Depositing real funds will likely lead to them being stolen by an attacker.
- **Key Rotation:** If an address is triggered and "burned", regenerate a new set of artifacts for that endpoint to maintain detection capabilities.
