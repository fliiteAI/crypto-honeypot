# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect if an attacker has successfully stolen a private key and is attempting to use it on the blockchain.

## Why Monitor On-Chain?

Even if an attacker manages to bypass local endpoint security and exfiltrate the honeypot files, they will eventually need to "check" the balances or attempt to move funds from the stolen keys. By monitoring the public addresses associated with your honeypots, you can:
- Confirm a successful exfiltration.
- Identify the attacker's wallet addresses (if they transfer funds).
- Gain intelligence on the attacker's tools and techniques.

## Setting Up Watchlists

### 1. Export Public Addresses
Use the `honeypot-deployer` CLI to export the public addresses of all generated honeypots:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watch-addresses.json
```

### 2. Import to Block Explorers
Most major block explorers allow you to create "Watchlists" that send email or webhook notifications for any activity.

- **Ethereum (EVM):** [Etherscan](https://etherscan.io/myaddress) (Address Watch List)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/) or [Solana Explorer](https://explorer.solana.com/)

### 3. Automated Monitoring (Advanced)
For high-volume deployments, you can use API-based monitoring services:
- **Alchemy Notify:** Webhooks for Ethereum and other EVM chains.
- **Tatum:** Unified API for monitoring multiple blockchains.
- **QuickNode:** Real-time stream of blockchain events.

## Security Warning
**NEVER deposit real funds into honeypot addresses.** These addresses are for detection purposes only. Any funds deposited will be at extreme risk of theft if the honeypot is triggered.
