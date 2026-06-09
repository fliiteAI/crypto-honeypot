# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) provides the ultimate confirmation of a successful theft. By watching the public addresses associated with your honeypot artifacts, you can detect when an attacker has successfully exfiltrated a private key and imported it into a wallet.

## How it Works

1. When you run `honeypot-deployer generate`, the tool creates unique private/public key pairs.
2. The private keys are embedded in the artifacts (e.g., `wallet.dat`, `id.json`).
3. The public addresses are stored in the `manifest.json`.
4. You export these addresses and add them to "Watchlists" on various blockchain explorers.
5. When the explorer detects activity on that address, it sends an alert (Email/Webhook).

## 1. Exporting Honeypot Addresses

Use the CLI to export all generated public addresses into a clean JSON format:

```bash
honeypot-deployer export-addresses --manifest ./honeypot-artifacts/manifest.json --output ./my-watchlist.json
```

The output will look like this:
```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["7x..."]
}
```

## 2. Setting Up Watchlists

We recommend using the following services for monitoring:

### Ethereum & EVM (ETH, BSC, Polygon)
- **Service:** [Etherscan](https://etherscan.io/) (and its sisters BscScan, PolygonScan).
- **Setup:** Create a free account -> My Profile -> Watch List -> Add New Address.
- **Notification:** Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
- **Setup:** Many Bitcoin explorers allow you to track addresses via their API or account dashboards.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/).
- **Setup:** Create an account -> Watchlist -> Add Address.

### XRP (Ripple)
- **Service:** [XRP Scan](https://xrpscan.com/).

---

## 3. Integrating with Wazuh

To bring on-chain alerts into your Wazuh dashboard:

1. **Webhooks:** Configure the block explorer to send a Webhook when activity occurs.
2. **Intermediate Script:** Use a simple script (or a tool like n8n/Zapier) to receive the webhook and write a log entry to a file monitored by the Wazuh Agent.
3. **Log Format:** Ensure the log entry includes the chain and address.

Example log format for Wazuh:
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x123...", "activity_type": "balance_query"}
```

Wazuh rules **100530 - 100533** are pre-configured to trigger on these logs.

## Security Note

**Never deposit real funds into honeypot addresses.** The goal is to detect the *attempt* to use the keys, not to provide a bounty for the attacker. Some automated "drainers" will attempt to send a small amount of gas money (ETH/SOL) to the wallet first to pay for the transaction fees of stealing your (non-existent) tokens. This is a high-fidelity indicator of an automated attack.
