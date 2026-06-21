# On-Chain Monitoring Guide

This guide explains how to set up real-time monitoring for your honeypot addresses on the blockchain.

## Overview

When an attacker steals a honeypot private key, their next step is usually to import it into a wallet and check for funds. By monitoring these addresses on-chain, you can detect when a compromise has occurred even if the attacker managed to bypass your endpoint security.

## 1. Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export all generated public addresses from your manifest.

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing the public addresses for Bitcoin, Ethereum, Solana, and any other enabled chains.

## 2. Set Up Block Explorer Watchlists

The easiest way to get notified of on-chain activity is to use the "Watchlist" or "Address Alert" features provided by major block explorers.

### Ethereum & EVM (Etherscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Select **Notify on Incoming & Outbound Txns**.
5. Repeat for other EVM chains (BSCSprint, Polygonscan, etc.) if you are monitoring them.

### Bitcoin (Blockchain.com, etc.)
1. Many Bitcoin explorers allow you to "Watch" an address.
2. Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or set up your own node with [Electrum Personal Server](https://github.com/chris-belcher/electrum-personal-server) for private monitoring.

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **Account Tracking** feature to add your Solana honeypot address.

---

## 3. Integrating with Wazuh (Advanced)

For a fully integrated security operations workflow, you can feed these on-chain alerts back into Wazuh.

### Using the `chain-monitor` Script
The `honeypot-deployer` project includes a `chain-monitor` utility (available in `src/honeypot_deployer/utils/`) that can poll block explorer APIs and generate logs that Wazuh can ingest.

1. **Configure API Keys:** Obtain API keys for Etherscan, Solscan, etc.
2. **Run the Monitor:**
   ```bash
   python -m honeypot_deployer.utils.chain_monitor \
     --addresses ./honeypot-addresses.json \
     --interval 60 \
     --log-file /var/log/honeypot-chain.log
   ```
3. **Wazuh Ingestion:** Ensure the Wazuh Manager is monitoring `/var/log/honeypot-chain.log` with the correct decoder.

### Alerting Levels
On-chain alerts are generally high priority:
- **Balance Query (via API):** Level 13 (Reconnaissance)
- **Outbound Transfer:** Level 15 (Active Theft)
- **Inbound Transfer (Small amount):** Level 12 (Attacker testing the wallet with "gas" or "dust")

---

## Security Best Practices

- **Never Deposit Real Funds:** The honeypot addresses must stay empty. Any balance suggests they are no longer pure honeypots.
- **Rotate Addresses:** If an address is "burned" (accessed by an attacker), generate a new deployment to maintain the honeypot's effectiveness.
- **Privacy:** Using public block explorers to watch your addresses does leak the fact that you are interested in those addresses to the explorer provider. For maximum privacy, run your own full node.
