# On-Chain Monitoring: Setting Up Watchlists

The final layer of detection in the Crypto Wallet Honeypot system is monitoring the generated bait addresses for on-chain activity. This allows you to confirm if an attacker has successfully exfiltrated and imported the "stolen" keys.

## Overview

When you generate honeypot artifacts using the CLI, a set of public addresses is created. These addresses are linked to the non-funded private keys stored in the honeypot files. By adding these addresses to "watchlists" on various block explorers, you can receive alerts whenever an attacker queries the balance or attempts a transaction.

## Exporting Honeypot Addresses

To get a clean list of your honeypot addresses for import into monitoring tools, use the `export-addresses` command:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watchlist.json
```

## Recommended Monitoring Tools

### 1. Ethereum & EVM Chains (Etherscan / Polygonscan / etc.)
Etherscan provides a "Watch List" feature that can send emails or webhooks when an address becomes active.

1. Create an account on [Etherscan.io](https://etherscan.io/).
2. Navigate to **Account** -> **Watch List**.
3. Add your generated Ethereum addresses.
4. Enable "All Transactions" notifications.

### 2. Solana (Solscan / Solana Explorer)
For Solana addresses, you can use Solscan's tracking features or specialized Solana monitoring bots.

- **Solscan:** Use the "Track" feature on specific addresses to receive notifications.
- **Telegram Bots:** Several Solana tracking bots (e.g., EtherDROPS) allow you to add Solana addresses and receive instant Telegram alerts.

### 3. Bitcoin (Blockchain.com / Mempool.space)
Bitcoin monitoring can be set up via various explorers that support address-based alerts.

- **Mempool.space:** Offers detailed views, though persistent alerting may require integration with a custom script or a third-party service like Blockonomics.

---

## Integrating with Wazuh

For a fully automated response, you can use the `chain-monitor` service (if configured) to ingest on-chain events directly into Wazuh. This triggers Rule ID `100530` and can be correlated with file access events (Rule ID `100540`).

### Chain Monitor Log Format
If you are building a custom script to bridge block explorer webhooks to Wazuh, ensure the logs are in JSON format and follow this structure:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "activity_type": "outbound_transfer",
  "chain": "ethereum",
  "address": "0x1234567890abcdef1234567890abcdef12345678",
  "txid": "0xabcdef...",
  "honeypot": "true"
}
```

These logs should be written to `/var/log/chain-monitor/events.json` on the Wazuh Manager, as configured in the [Log Collection Guide](DEPLOYMENT.md).
