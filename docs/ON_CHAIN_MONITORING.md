# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully exfiltrated a private key or seed phrase and imported it into a wallet to check for funds or attempt a transaction.

## Overview

When you generate honeypot artifacts using the `honeypot-deployer` CLI, the public addresses associated with those keys are stored in the `manifest.json`. You can export these addresses and add them to various block explorer "watchlists" to receive real-time alerts.

## Exporting Addresses

Use the CLI to export all generated addresses in a format suitable for import:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watchlists.json
```

## Setting Up Watchlists

### 1. Ethereum & EVM Chains (Etherscan, Polygonscan, etc.)
- Create a free account on [Etherscan](https://etherscan.io/).
- Navigate to **Account** -> **Watch List**.
- Add your honeypot ETH addresses.
- Enable "Notify on Incoming & Outgoing Txns".

### 2. Solana (Solscan)
- Create an account on [Solscan](https://solscan.io/).
- Use the **Watchlist** feature to add your SOL addresses.
- Configure email or webhook notifications.

### 3. Bitcoin (Blockchain.com / Mempool.space)
- Many Bitcoin explorers offer address tracking services.
- For professional monitoring, consider using a self-hosted Electrum Personal Server or a service like [Mempool.space](https://mempool.space/) (via their API or web interface if supported).

## Monitoring Strategy

- **Incoming Transactions:** Sometimes attackers (or automated bots) might send a small amount of "dust" (very small amount of crypto) to an address before attempting a larger withdrawal.
- **Outgoing Transactions:** This is a critical alert. It means the attacker is attempting to move funds (even if the wallet is empty, they may try to send a transaction which will fail due to lack of gas).
- **Balance Queries:** While harder to track via public watchlists, some advanced monitoring tools can alert on "Balance Discovery" if they have access to node provider logs.

## Handling On-Chain Alerts

If you receive an on-chain alert:
1. **Correlate with Wazuh:** Check your Wazuh dashboard for any FIM or Audit alerts that occurred *prior* to the on-chain activity.
2. **Identify the Endpoint:** Use the Wazuh alerts to identify which machine was compromised.
3. **Initiate Incident Response:** The fact that on-chain activity occurred confirms that the private key was successfully exfiltrated and used by an attacker.
