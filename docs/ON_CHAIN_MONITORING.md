# On-Chain Monitoring Guide

This guide explains how to monitor generated honeypot addresses on the blockchain to detect when an attacker imports and interacts with stolen keys.

## Overview

The `honeypot-deployer` generates real cryptocurrency public/private key pairs. While the private keys are deployed as bait, the public addresses should be added to "Watchlists" on various block explorers. This provides an out-of-band detection mechanism (Layer 4) that works even if the attacker successfully exfiltrates the data and disconnects from your network.

## 1. Export Honeypot Addresses

First, use the CLI to export all generated addresses from your manifest:

```bash
honeypot-deployer export-addresses --manifest ./honeypot-artifacts/manifest.json --output monitored-addresses.json
```

This will create a JSON file categorized by chain (e.g., BTC, ETH, SOL).

## 2. Setting Up Watchlists

Add the exported addresses to the following services to receive real-time alerts (email, webhook, or Telegram).

### Ethereum / EVM (ETH)
- **Service:** [Etherscan.io](https://etherscan.io/)
- **Feature:** Watch List
- **Setup:** Create a free account, go to "My Watch List", and add the Ethereum addresses. Enable "Email Notifications" for all incoming and outgoing transactions.

### Bitcoin (BTC)
- **Service:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Many Bitcoin explorers offer address tracking. For programmatic monitoring, consider using a lightweight node or a tracking API.

### Solana (SOL)
- **Service:** [Solscan.io](https://solscan.io/)
- **Feature:** Account Tracking
- **Setup:** Create an account and add the Solana addresses to your monitored accounts list.

### Ripple (XRP)
- **Service:** [XRP Scan](https://xrpscan.com/)
- **Setup:** Use their subscription service or API to monitor for account activations or payments.

### Cardano (ADA)
- **Service:** [Cardanoscan](https://cardanoscan.io/)
- **Setup:** Monitor the `.skey` associated addresses for any movement.

## 3. Interpreting Activity

If you receive an alert from a block explorer:

1. **Inbound Transaction (Dusting):** Attackers often send a tiny amount of crypto (dust) to an address to see if it's active or if it's being monitored. This is a high-fidelity indicator that the key has been compromised.
2. **Outbound Transaction:** The attacker is attempting to move funds. Since these are honeypot addresses, they should be empty, but any outbound signature proves the private key is in the attacker's possession.
3. **On-Chain Message:** Some attackers send messages via transaction input data.

## 4. Automation (Optional)

For enterprise environments, you can ingest block explorer webhooks directly into Wazuh using a custom integration or by logging them to a file monitored by the Wazuh agent.
