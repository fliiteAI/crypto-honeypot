# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker has imported a stolen honeypot key into a wallet and is interacting with it on the blockchain.

## Why Monitor On-Chain?

While FIM and process auditing detect the *act* of theft, on-chain monitoring confirms the *success* of the theft. It provides definitive proof that the credentials have been compromised and are being actively used.

## How to Export Honeypot Addresses

The `honeypot-deployer` CLI provides a command to export the public addresses of all generated honeypots in a format suitable for monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-to-monitor.json
```

## Recommended Monitoring Tools

### Block Explorers (Watchlists)
Most major block explorers allow you to create "Watchlists" that send email or webhook notifications when activity occurs on a specific address.

- **Ethereum/EVM:** [Etherscan](https://etherscan.io/)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **XRP:** [XRP Scan](https://xrpscan.com/)

### Specialized Monitoring Services
For more advanced setups, consider services that provide APIs for real-time blockchain monitoring:

- **Alchemy (Notify API):** Supports Ethereum, Polygon, Solana, and more.
- **Tatum:** Provides webhooks for multiple chains.
- **QuickNode:** Offers real-time event monitoring.

## What to Look For

- **Incoming Transactions:** Even small "dust" transactions might indicate an attacker testing the wallet.
- **Outgoing Transactions:** A clear sign that an attacker is attempting to move funds (or what they believe are funds).
- **Contract Interactions:** If the stolen key is used to interact with DeFi protocols or other smart contracts.

## Integration with Wazuh

While on-chain activity happens outside the local system, you can integrate these alerts back into Wazuh for a centralized view:

1. Use a script to poll block explorer APIs for activity on your exported addresses.
2. Log any detected activity to a file monitored by the Wazuh agent.
3. Use the custom Wazuh rules (e.g., Rule ID 100530) to trigger alerts.
