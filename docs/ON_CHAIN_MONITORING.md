# On-Chain Monitoring Guide

On-chain monitoring is the fourth and final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully exfiltrated a honeypot key and is attempting to use it on the blockchain.

## How It Works

When you generate honeypot artifacts using the `honeypot-deployer` CLI, it creates a `manifest.json` (usually encrypted) that contains both the private keys (deployed as artifacts) and their corresponding public addresses.

By importing these public addresses into a monitoring service, you can receive alerts whenever:
1. An attacker checks the balance of a stolen account.
2. An attacker attempts to send a transaction from a stolen account.
3. An attacker deposits "gas" funds into a stolen account to facilitate a transfer.

## Setting Up Monitoring

### 1. Export Honeypot Addresses
Use the CLI to export a list of all public addresses in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

### 2. Choose a Monitoring Service
You can use various block explorers and monitoring services depending on the chain:

#### Ethereum / EVM (Etherscan)
- Go to [Etherscan Watchlist](https://etherscan.io/myaddress).
- Create a free account.
- Add your honeypot ETH addresses.
- Configure "Email Notifications" for any incoming or outgoing transactions.

#### Bitcoin (Blockchain.com / Blockonomics)
- Use [Blockonomics](https://www.blockonomics.co/) or [Blockchain.com](https://www.blockchain.com/explorer) to create watch-only wallets.
- Import your honeypot BTC addresses.

#### Solana (Solscan)
- Use [Solscan](https://solscan.io/) and create an account to use their "Account Tracking" feature.

### 3. Automated Monitoring (Advanced)
For large-scale deployments, you can use the exported `watch-list.json` with a custom script or a service like **Tenderly** or **Alchemy Notify** to receive Webhook alerts directly into your SIEM or Slack.

## Security Warning
**NEVER** deposit real funds into these honeypot addresses. The private keys for these addresses are deployed on potentially compromised endpoints as part of the honeypot. Any funds sent to these addresses should be considered lost.
