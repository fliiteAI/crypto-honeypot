# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has successfully stolen your honeypot keys and is interacting with them on the blockchain.

## How It Works

1.  **Generate Bait Addresses:** Use the `honeypot-deployer` CLI to generate randomized wallet artifacts.
2.  **Export Public Addresses:** Extract the public addresses associated with those artifacts.
3.  **Setup Watchlists:** Import these addresses into blockchain explorers or monitoring services.
4.  **Receive Alerts:** Get notified when a transaction occurs or when the address is queried.

## Step-by-Step Instructions

### 1. Export Public Addresses
After generating your honeypot artifacts, run the following command to get a JSON list of all public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

### 2. Configure Monitoring Services

We recommend using the following services for each chain:

#### Ethereum & EVM (Polygon, BSC, etc.)
- **Service:** [Etherscan Watchlist](https://etherscan.io/myaddress)
- **Setup:** Create a free account and add your exported ETH addresses.
- **Notification:** Enable email notifications for "Incoming & Outgoing" transactions.

#### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Many BTC explorers allow you to "Follow" an address via email or webhook.

#### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/) or [Helius](https://www.helius.dev/)
- **Setup:** Solscan provides a "Watchlist" feature for registered users. Helius is excellent for setting up real-time webhooks for developer-centric setups.

### 3. Interpreting Alerts

- **Zero-Value Transactions:** Attackers often send a tiny amount of native currency (gas) to a stolen address to test if the keys work before attempting to sweep other assets.
- **Token Approval Events:** If your honeypot includes fake tokens, look for `Approve` or `IncreaseAllowance` transactions.
- **Query Events:** Some advanced monitoring services can detect when an address is merely *queried* via an RPC provider, though this is less common for public explorers.

## Security Warning

**NEVER deposit real funds into these honeypot addresses.** The private keys are stored on your monitored endpoints and in your `manifest.json`. If an attacker finds them, they can and will sweep any funds they find.

The goal of this layer is not to "catch" the money, but to confirm that the credentials exfiltrated in Layer 1/2/3 are actively being used by the threat actor.
