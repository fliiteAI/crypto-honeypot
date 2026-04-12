# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to track an attacker even after they have successfully exfiltrated honeypot keys from a compromised endpoint.

## How It Works

When you generate honeypot artifacts using the `honeypot-deployer`, the tool creates a set of public addresses associated with the generated private keys. By importing these addresses into public block explorer "watchlists," you can receive notifications whenever an attacker:
1. Imports the stolen key into a wallet.
2. Queries the balance of the address.
3. Attempts to transfer funds from the address.
4. Interacts with DeFi protocols (e.g., token approvals).

## Step 1: Export Honeypot Addresses

Use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

The output file will contain a list of addresses categorized by blockchain (BTC, ETH, SOL, etc.).

## Step 2: Set Up Watchlists

Import the exported addresses into the following services to receive real-time alerts:

### Ethereum & EVM Chains
- **Service:** [Etherscan](https://etherscan.io/) (and similar explorers like Polygonscan, BSCScan).
- **Feature:** "Watch List" (requires a free account).
- **Notification:** Email or Webhook alerts for any transaction.

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
- **Feature:** Address tracking/notifications.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/) or [SolanaFM](https://solanafm.com/).
- **Feature:** Monitor address activity.

## Step 3: Integrate with Wazuh

To feed these alerts back into Wazuh for centralized alerting:
1. Configure your chosen block explorer to send webhook notifications.
2. Use a simple integration script (or a tool like n8n/Zapier) to forward these webhooks to the Wazuh Manager API or a monitored log file.
3. Wazuh rules `100530` through `100533` are pre-configured to handle these events if they are formatted as JSON.

## Important Security Note

**Never deposit real funds into these addresses.** The private keys are considered compromised as soon as they are deployed as honeypots. The goal is to detect the *attacker's* activity, not to store assets.
