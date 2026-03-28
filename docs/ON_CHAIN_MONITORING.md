# On-Chain Monitoring Guide: Crypto Wallet Honeypot

The final layer of the Crypto Wallet Honeypot's 4-layer detection strategy is **On-Chain Monitoring**. This guide explains how to track the generated honeypot addresses on the blockchain to detect if an attacker has successfully exported and imported the stolen keys.

## Overview

When you generate artifacts using the `honeypot-deployer` CLI, each generated wallet has a unique, non-funded public address. If an attacker steals the private keys from your endpoint, their next step is often to import them into a wallet application (like MetaMask or Electrum) and query the balance or attempt to move funds.

By monitoring these addresses on-chain, you can confirm a successful compromise even if the attacker managed to evade local endpoint detection.

## 1. Export Honeypot Addresses

Use the `export-addresses` command to get a JSON file containing all public addresses generated in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

The output will be a JSON object like this:

```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["..."]
}
```

## 2. Setting Up Watchlists

You can monitor these addresses using several methods:

### Method A: Block Explorer Watchlists (Recommended)
Most major block explorers allow you to create a free account and set up "Watchlists" that send you an email notification for any activity on a specific address.

| Chain | Recommended Explorer | Feature Name |
|-------|----------------------|--------------|
| **Bitcoin** | [Blockchain.com](https://www.blockchain.com/explorer) | Watchlist |
| **Ethereum** | [Etherscan](https://etherscan.io/) | Watch List |
| **Solana** | [Solscan](https://solscan.io/) | Account Tracker |
| **XRP** | [XRP Scan](https://xrpscan.com/) | Account Watch |

### Method B: Custom Monitoring Scripts
For a more automated approach, you can create a simple script that polls the block explorer APIs (e.g., Etherscan API, Alchemy, QuickNode) and sends alerts to your Wazuh Manager or a Slack/Discord webhook.

### Method C: Wazuh Chain Monitor Integration
The `honeypot-deployer` is designed to work with a custom `chain-monitor` service (coming soon) that automatically reads the exported addresses and feeds activity logs directly into the Wazuh Manager.

## 3. Interpreting Activity

| Activity Type | Severity | Description |
|---------------|----------|-------------|
| **Balance Query** | Medium | The attacker has imported the key and is checking if it contains funds. |
| **Small Inbound Transfer** | High | The attacker may be "dusting" the account or testing if they can move funds in. |
| **Outbound Transfer Attempt** | Critical | The attacker is actively trying to drain the account. **Confirmed Compromise.** |

## 4. Response Actions

If you detect on-chain activity on a honeypot address:
1. **Identify the Source:** Use the `manifest.json` to identify which endpoint and which user account the address was deployed to.
2. **Isolate the Endpoint:** Immediately isolate the affected machine from the network.
3. **Forensic Analysis:** Examine the Wazuh alerts (Layer 1-3) on that endpoint to identify the attacker's initial entry point and toolset.
4. **Credential Rotation:** Assume all other secrets on that endpoint have been compromised.
