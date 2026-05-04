# On-Chain Monitoring Guide

On-chain monitoring is the final and most definitive layer of the honeypot system. It detects when an attacker attempts to use the exfiltrated private keys on the actual blockchain.

## Overview

Even if an attacker manages to bypass endpoint detection and successfully steals a honeypot key, they must eventually interact with the blockchain to check for funds or transfer them. By monitoring the public addresses associated with our honeypots, we get a "true positive" signal that the keys have been compromised.

## Step 1: Export Honeypot Addresses

After generating your honeypot artifacts, use the CLI to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watch-list.json
```

This will create a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Block Explorer Watchlists

Add the exported addresses to the "Watchlist" or "Alert" feature of major block explorers.

### Recommended Explorers:
- **Ethereum / EVM:** [Etherscan](https://etherscan.io/) (requires a free account)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **Cardano:** [Cardanoscan](https://cardanoscan.io/)

### Configuration:
- Set up **Email Alerts** for any incoming or outgoing transactions.
- If the explorer supports it, monitor for **Balance Queries** (though this is less common for public explorers).

## Step 3: Integrate with Wazuh (Advanced)

For automated correlation, you can use a custom script or an external integration to feed blockchain events into Wazuh.

1. **Webhooks:** Many block explorers offer webhooks for address activity.
2. **Custom Script:** Run a small script that polls the explorer APIs for your honeypot addresses and writes events to a log file monitored by the Wazuh Agent.
3. **Wazuh Rules:** Use the custom rules (e.g., ID 100530) to alert when these logs indicate activity.

## Important Safety Notes

- **NO REAL FUNDS:** Never deposit real cryptocurrency into any honeypot address. The goal is to detect the *attempt* to steal, not to provide a bounty.
- **Dust Attacks:** Be aware of "dust attacks" where random small amounts of crypto are sent to addresses. Differentiate these from the attacker's activity by looking for correlation with endpoint alerts.
- **Gas Fees:** The attacker will often need to send a small amount of "gas" (e.g., ETH or SOL) to the honeypot address before they can move any (non-existent) funds. This incoming transaction is a critical indicator.
