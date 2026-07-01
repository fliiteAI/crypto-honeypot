# On-Chain Monitoring Guide

This guide explains how to monitor your honeypot addresses on the blockchain to detect when an attacker imports and uses stolen keys.

## Overview

Even if an attacker successfully exfiltrates your honeypot keys without triggering an endpoint alert, they will eventually need to interact with the blockchain to check balances or move funds. By monitoring these addresses, you gain a final, foolproof layer of detection.

## 1. Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watch-addresses.json
```

This will produce a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## 2. Set Up Block Explorer Watchlists

The easiest way to get real-time alerts is to use "Watchlist" features provided by major block explorers.

### Ethereum & EVM (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **Account** -> **Watch List**.
3. Click **Add** and paste your honeypot ETH addresses.
4. Set "Notification Method" to Email or Webhook.
5. Repeat for other EVM chains (BscScan, Polygonscan, etc.) if you deployed multiple.

### Bitcoin (Blockchain.com / Mempool.space)
- Use [Mempool.space](https://mempool.space) to manually check addresses or use their API for automated monitoring.
- Many hardware wallet interfaces or portfolio trackers can also be used to "watch" these addresses.

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **My Watchlist** feature to add your `id.json` public keys.
3. Configure email notifications for any transaction activity.

---

## 3. Advanced: Automated Monitoring with Wazuh

For a more integrated experience, you can feed block explorer webhooks into Wazuh.

### Using the `chain-monitor` Script
The `honeypot-deployer` package includes (or can be extended with) a background script that polls block explorer APIs and logs activity to a format Wazuh understands.

1. **Configure API Keys:** Set your Etherscan/Solscan API keys in your environment.
2. **Run Monitor:**
   ```bash
   honeypot-deployer chain-monitor --manifest ./manifest.json
   ```
3. **Wazuh Integration:** Wazuh will pick up these logs (if configured in `ossec.conf`) and trigger rules 100530-100533.

---

## What to do if an alert fires?

An on-chain alert on a honeypot address is a **100% confirmed compromise**.

1. **Immediate Isolation:** Isolate the endpoint(s) associated with that manifest.
2. **Trace the Leak:** Check Wazuh logs for Layer 1/2/3 alerts around the time the manifest was generated or deployed.
3. **Forensics:** Use the Wazuh Active Response forensic snapshots to see what was running on the machine when the keys were likely stolen.
4. **Assume Full Breach:** If one honeypot was taken, assume other (real) credentials on that machine are also compromised.
