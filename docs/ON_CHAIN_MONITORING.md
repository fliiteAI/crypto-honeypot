# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection. It allows you to track if an attacker has successfully exfiltrated a private key and is attempting to use it.

## 1. Export Honeypot Addresses

First, use the CLI to export all public addresses generated for your honeypots.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

The output file will contain a list of addresses mapped by chain:

```json
{
  "eth": ["0x123...", "0x456..."],
  "btc": ["bc1q...", "1..."],
  "sol": ["7vN...", "9xW..."]
}
```

## 2. Set Up Watchlists

You should add these addresses to "Watchlists" or "Address Trackers" on major block explorers. Most explorers offer free alerts (email or webhook) when an address receives or sends a transaction.

### Recommended Explorers

- **Ethereum / EVM:** [Etherscan](https://etherscan.io/) (and its variants for Polygon, BSC, etc.)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **XRP:** [Bithomp](https://bithomp.com/)
- **Cardano:** [Cardanoscan](https://cardanoscan.io/)

## 3. Advanced Monitoring (Webhooks)

For professional deployments, use developer-focused APIs that provide real-time webhooks for address activity.

- **Alchemy:** [Notify API](https://www.alchemy.com/notify)
- **QuickNode:** [Streams](https://www.quicknode.com/streams)
- **Tatum:** [Notifications](https://tatum.io/features/notifications)

## 4. What to Look For

Since these honeypots are non-funded, any activity is highly suspicious:
- **Small Deposits:** Attackers may send a small amount of gas money (ETH, SOL) to the address to pay for the transaction fees required to move other (imaginary) assets.
- **Nonce Increases:** On EVM chains, even if a transaction fails, the account's nonce will increase.
- **Contract Interactions:** Attempts to call `transfer` on common token contracts (USDT, USDC).

## 5. Responding to On-Chain Alerts

If an on-chain alert is triggered:
1. Identify the compromised endpoint by looking up the address in your `manifest.json`.
2. Assume the endpoint is fully compromised.
3. Initiate your Incident Response (IR) plan, including forensic imaging and network isolation.
