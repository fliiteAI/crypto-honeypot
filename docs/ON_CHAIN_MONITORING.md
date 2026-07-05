# On-Chain Monitoring Guide

On-chain monitoring is the fourth layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect if an attacker has successfully exfiltrated the honeypot keys and is now attempting to use them.

## Overview

Even if an attacker bypasses local detection or exfiltrates data from an unmonitored host, they will eventually need to use the stolen keys on a blockchain to check balances or move funds. By monitoring the public addresses of our honeypots, we can confirm a successful compromise and gain intelligence on the attacker's activities.

## 1. Exporting Honeypot Addresses

After generating your honeypot artifacts, use the CLI to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watch-list.json
```

This will create a JSON file containing all the public addresses for each chain (BTC, ETH, SOL, etc.).

## 2. Setting Up Watchlists

You can monitor these addresses using several methods:

### Block Explorer Watchlists (Easiest)
Most popular block explorers offer "Watchlist" or "Alert" services that will email you when activity is detected on a specific address.

- **Ethereum/EVM:** [Etherscan](https://etherscan.io/) (requires free account)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **Multi-chain:** [DeBank](https://debank.com/)

### Custom Webhooks (Advanced)
For professional or automated monitoring, you can use API services to receive webhooks:

- **Alchemy / Infura:** Set up "Address Activity" notifications.
- **Tatum:** Use "Address Notifications" across multiple chains.
- **QuickNode:** Utilize "QuickAlerts" for real-time monitoring.

## 3. Integrating with Wazuh

To feed on-chain alerts back into Wazuh for centralized logging:

1. Configure your monitoring service to send a webhook or email.
2. If using a webhook, use a simple relay script to log the event to a file monitored by the Wazuh agent.
3. The event should be in JSON format and include:
   - `source`: "chain-monitor"
   - `chain`: (e.g., "ethereum")
   - `address`: (the honeypot address)
   - `activity_type`: (e.g., "balance_query", "transfer")

Example log entry:
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "ethereum", "address": "0x123...", "activity_type": "outbound_transfer"}
```

Wazuh will automatically match this against rule ID `100530` or higher.

## 4. Response Actions

When an on-chain alert is triggered:
- **Immediate Compromise Confirmation:** A successful on-chain query confirms that the attacker has the private keys.
- **Trace the Source:** Look back at your Wazuh logs to find which endpoint was accessed around the time the keys were stolen (use rule `100540` for automated correlation).
- **Rotate Authorized Keys:** If an attacker has compromised one part of your environment, assume they may have access to others.
