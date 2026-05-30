# On-Chain Monitoring Guide

On-chain monitoring (Detection Layer 4) is a critical component of the Crypto Wallet Honeypot system. It allows you to detect if an attacker has successfully exfiltrated a private key and is attempting to use it, even if host-based alerts were missed or suppressed.

## Overview

When you generate honeypot artifacts, the system also tracks the public addresses associated with those "bait" keys. By adding these addresses to "watchlists" on various block explorers, you can receive automated notifications of any balance queries or transactions.

## 1. Export Honeypot Addresses

First, use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watchlists/addresses.json
```

This will create a JSON file organized by chain:

```json
{
  "btc": ["bc1q...", "3..."],
  "eth": ["0x..."],
  "sol": ["..."]
}
```

## 2. Setting Up Watchlists

### Ethereum & EVM Chains (Etherscan / PolyganScan / etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** -> **Watch List**.
3. Click **Add** and paste your exported Ethereum addresses.
4. Set "Notification Method" to "Email" or "Webhook".
5. Enable "Track ERC-20 Tokens" to detect if the attacker attempts to check for token balances.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
2. Many explorers allow you to "Follow" an address via RSS or email notifications.
3. For enterprise setups, consider using a dedicated Bitcoin node with `watch-only` wallets imported.

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **My Watchlist** feature.
3. Add your exported Solana addresses to receive alerts for any SOL or SPL token activity.

## 3. Integrating with Wazuh

While block explorers provide external alerts, you can integrate these into your Wazuh dashboard for a unified view.

### Using Webhooks
If your chosen block explorer supports Webhooks (like Etherscan's premium API or services like Alchemy/QuickNode):
1. Configure the explorer to send a POST request to a custom endpoint.
2. Use a simple script to log these requests to a file monitored by the Wazuh Agent.
3. The `honeypot_rules.xml` already includes a rule (ID `100530`) for on-chain activity.

### Custom Script (Periodic Check)
You can write a simple Python script to periodically query the balances of your honeypot addresses via public APIs and log any changes:

```python
# Pseudo-code for balance checker
import requests

addresses = ["0x123...", "0x456..."]
for addr in addresses:
    resp = requests.get(f"https://api.etherscan.io/api?module=account&action=balance&address={addr}")
    # Log to /var/log/honeypot-onchain.log if activity is detected
```

## 4. Response Strategy

If an on-chain alert is triggered:
1. **Immediate Isolation:** Assume the endpoint associated with that specific address in the manifest is compromised.
2. **Forensic Analysis:** Review Wazuh alerts for that host leading up to the on-chain activity.
3. **Key Rotation:** If the attacker is testing keys, they may have access to other legitimate credentials on the same machine. Begin your incident response and credential rotation process immediately.

---

**Note:** Never deposit real funds into honeypot addresses. The goal is to detect *interest* and *activity*, not to track the movement of actual assets.
