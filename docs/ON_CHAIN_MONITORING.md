# On-Chain Monitoring Guide

On-chain monitoring is Layer 4 of our detection strategy. It allows you to detect if an attacker has successfully exfiltrated a private key and imported it into a wallet, even if they bypassed all endpoint-level detections.

## How it Works

1. **Deployment:** The `honeypot-deployer` generates a unique private key and a corresponding public address for each deployed artifact.
2. **Export:** You export these public addresses using the CLI.
3. **Watchlist:** You import these addresses into a "Watchlist" on various block explorers or monitoring services.
4. **Alert:** When the attacker (or their automated bot) queries the balance or attempts a transaction, the monitoring service sends an alert (Email, Webhook, Telegram).

## Exporting Addresses

Use the CLI to generate a list of all public addresses in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-addresses.json
```

The output will include addresses for all supported chains:
- **BTC:** SegWit (bech32) or Legacy addresses.
- **ETH:** 0x... addresses (applicable to all EVM chains like BSC, Polygon, Avalanche).
- **SOL:** Base58 Solana addresses.
- **XRP:** Ripple addresses.
- **ADA:** Cardano addresses.

## Recommended Monitoring Services

| Chain | Recommended Service | Feature to Use |
|-------|---------------------|----------------|
| **Ethereum / EVM** | [Etherscan](https://etherscan.io/) | Watchlist (Address Tracking) |
| **Bitcoin** | [Blockchain.com](https://blockchain.com/) | Wallet Watchlist |
| **Solana** | [Solscan](https://solscan.io/) | Account Alerts |
| **Multi-Chain** | [Tenderly](https://tenderly.co/) | Real-time Alerting |

## Operational Security (OPSEC)

- **NEVER** deposit real funds into these addresses. The presence of *any* balance will attract more attention from sophisticated attackers and may lead to automated "sweeper" bots draining the funds.
- **Monitor for Balances:** A balance appearing on a honeypot address is a critical indicator. It may mean an attacker is using the address for money laundering or testing.
- **Zero Balance Monitoring:** Most services allow you to alert on *any* transaction, even if the balance is zero. This is the preferred method for honeypots.
