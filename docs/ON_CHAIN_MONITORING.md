# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully exfiltrated a private key and is attempting to use it.

## Overview

The `honeypot-deployer` generates real cryptocurrency public/private key pairs. While the wallets are not funded, the fact that an attacker is querying their balance or attempting a transaction is a 100% high-fidelity indicator of a compromise.

## 1. Exporting Addresses

To begin monitoring, you first need to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-to-monitor.json
```

## 2. Setting Up Watchlists

You can use various block explorer services to set up alerts (email, webhook, or Telegram) for these addresses.

### Ethereum (ETH / ERC-20)
- **Service:** [Etherscan Watchlist](https://etherscan.io/myaddress)
- **Setup:** Create a free account, upload your exported ETH addresses, and enable "Notify on Incoming & Outgoing Txns".
- **API:** Use the Etherscan API `account/txlist` endpoint to build a custom automated monitor.

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Monitor the specific `bc1...` or `1...` addresses generated in the manifest.

### Solana (SOL / SPL)
- **Service:** [Solscan](https://solscan.io/) or [Helius](https://www.helius.dev/)
- **Setup:** Use Helius webhooks to get real-time alerts when any of your honeypot addresses are mentioned in a transaction.

## 3. Interpreting Alerts

If you receive an on-chain alert for a honeypot address:

1. **Confirm the Address:** Check the address against your `manifest.json` to identify which endpoint was compromised.
2. **Immediate Incident Response:** The attacker has already exfiltrated the keys. You must assume the host is fully compromised.
3. **Forensic Analysis:** Check Wazuh logs for Layer 1-3 alerts corresponding to the time of exfiltration to identify the attacker's methodology.

## 4. Automated Monitoring (Advanced)

For enterprise deployments, it is recommended to use a small Python script that polls block explorer APIs and forwards events to your SIEM or alerting pipeline.

Example using the `addresses-to-monitor.json`:

```python
import json
import requests

# Load exported addresses
with open('addresses-to-monitor.json', 'r') as f:
    monitor_list = json.load(f)

# Loop through and check balances/activity via API
# (Implementation depends on the specific chain's API)
```

## Security Warning

**NEVER deposit real funds into honeypot addresses.** The purpose is to detect access, not to provide bait money. Any funds deposited will likely be lost to the attacker or automated bots.
