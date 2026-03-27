# On-Chain Monitoring: Tracking Stolen Keys

The Crypto Wallet Honeypot system includes Layer 4 detection: monitoring the blockchain for any activity involving the generated honeypot addresses. This is a critical step to confirm if a stolen key has been imported and used by an attacker.

## Overview

When you generate honeypot artifacts, the `honeypot-deployer` also exports a list of the corresponding public addresses to a file named `chain-monitor-addresses.json`. These addresses can be added to watchlists on various block explorer services to provide near real-time alerts on any on-chain activity.

## Step 1: Export Honeypot Addresses

After generating your artifacts, run the following command to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This will create a JSON file containing all the generated addresses for each supported chain (BTC, ETH, SOL, XRP, ADA).

## Step 2: Configure Block Explorer Watchlists

Add each of your honeypot addresses to a "Watchlist" or "Address Alert" service. Most major block explorers offer this for free (often requiring an account).

### Ethereum (ETH/EVM)
- **Service:** [Etherscan](https://etherscan.io/)
- **Setup:** Go to **My Profile** > **Watch List** > **Add**.
- **Alert Type:** Receive an email when an address is involved in a transaction (incoming/outgoing).

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Search for your address and use the "Watch" or "Notify" feature if available.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Use the Solscan API or account notifications to monitor your `id.json` addresses.

### XRP Ledger
- **Service:** [Bithomp](https://bithomp.com/)
- **Setup:** Use their alert service to monitor Ripple addresses.

### Cardano (ADA)
- **Service:** [Cardanoscan](https://cardanoscan.io/)
- **Setup:** Monitor the generated `.skey` corresponding addresses.

## Step 3: Integrating with Wazuh (Optional)

For more advanced setups, you can use a custom script to poll these block explorers and feed the activity back into Wazuh as a log event. This allows Layer 4 alerts to appear directly in your Wazuh dashboard (Rule ID 100530).

**Note:** Never deposit real funds into these honeypot addresses. Any activity on these addresses is a definitive indicator of compromise.
