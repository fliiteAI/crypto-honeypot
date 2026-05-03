# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection. It ensures that even if an attacker successfully exfiltrates a wallet and bypasses endpoint detection, you are alerted when they attempt to use or query the stolen keys.

## 1. Export Public Addresses

After generating your honeypot artifacts, use the CLI to export the public addresses. This command extracts only the public keys/addresses, leaving the private keys secure in your manifest.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## 2. Set Up Watchlists

Import the addresses from `watch-list.json` into the "Watchlist" or "Address Monitor" feature of major block explorers. Most explorers offer free email or webhook notifications for address activity.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot ETH addresses.
4. Enable "Notify on Incoming & Outgoing Txns".

### Solana (Solscan)
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **Address Monitor** feature to track your `id.json` addresses.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use services like [Mempool.space](https://mempool.space/) or specialized wallet trackers to monitor for any transactions involving your `wallet.dat` addresses.

## 3. Interpreting Activity

Since these honeypots are **never funded**, any on-chain activity is a 100% confirmed indicator of compromise (IoC).

- **Balance Check:** If an address is queried on a block explorer, it suggests an attacker is verifying the "loot".
- **Incoming Transaction:** Attackers may send a small amount of "gas" (e.g., ETH or SOL) to the honeypot address to pay for transaction fees before moving what they believe are valuable tokens.
- **Outgoing Transaction:** Definitive proof that the private key has been imported and used.

## 4. Automation via Webhooks

For advanced users, many block explorers (like [Alchemy](https://www.alchemy.com/) or [Moralis](https://moralis.io/)) provide Webhook APIs. You can point these webhooks to a custom listener or back into your SIEM to trigger automated incident response workflows.
