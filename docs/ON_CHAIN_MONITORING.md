# On-Chain Monitoring Guide

On-chain monitoring is the fourth and final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully exfiltrated a private key and is attempting to use it on the blockchain.

## Overview

Even if an attacker manages to bypass local endpoint security and exfiltrate your honeyfiles, they must eventually "touch" the blockchain to realize any value from the stolen keys. By monitoring the public addresses associated with your honeypots, you can confirm a successful compromise and track the attacker's post-exploitation activity.

## Step 1: Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export the public addresses generated during the artifact creation process.

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./watch-list.json
```

This will create a JSON file containing the addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## Step 2: Set Up Watchlists

You can monitor these addresses using various public block explorer services that offer "Watchlist" or "Address Alert" features.

### Ethereum & EVM (ETH, BSC, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) (or its chain-specific equivalents like BscScan, Polygonscan).
- **Setup:** Create a free account, navigate to "Watch List," and add your exported Ethereum addresses.
- **Alerts:** Configure email notifications for any "Incoming & Outgoing" transactions.

### Bitcoin (BTC)
- **Service:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
- **Setup:** Many explorers allow you to "Follow" an address.
- **Advanced:** For production environments, consider running a lightweight Bitcoin node and using `bitcoind` watch-only wallets.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
- **Setup:** Use the "Track" feature to monitor your generated Solana `id.json` addresses.

### XRP Ledger (XRP)
- **Service:** [XRP Scan](https://xrpscan.com/).
- **Setup:** Monitor the account for any "Payment" or "AccountSet" transactions.

## Step 3: Integrating with Wazuh (Advanced)

To bring on-chain alerts into your Wazuh dashboard, you can use a custom script (the "Chain Monitor") that polls these explorers via API and sends JSON logs to your Wazuh Manager.

### Example Log Format
The Wazuh rules in `honeypot_rules.xml` (specifically rules 100530-100533) expect logs in the following JSON format:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabcdef...",
  "amount": "0.0",
  "timestamp": "2023-10-27T10:00:00Z"
}
```

### Feeding Logs to Wazuh
You can send these logs to Wazuh using the `logger` command on Linux or by writing to a local file monitored by the Wazuh Agent's `logcollector`.

```bash
# Example using logger
echo '{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x1234...", "activity_type": "balance_query"}' | logger -t chain-monitor
```

## Security Best Practices
- **NEVER deposit real funds** into honeypot addresses.
- Keep your `manifest.json` encrypted. The public addresses are safe to share with explorer services, but the private keys must remain secret.
- If an on-chain alert triggers, assume the endpoint where that specific artifact was deployed is fully compromised.
