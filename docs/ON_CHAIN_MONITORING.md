# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final piece of the detection strategy. It allows you to track an attacker even after they have successfully exfiltrated honeypot wallet files from your network.

## How it Works

1. **Generation:** When you generate honeypot artifacts, the `honeypot-deployer` creates real public/private key pairs for various blockchains (BTC, ETH, SOL, etc.).
2. **Exfiltration:** An attacker steals these "credentials" and imports them into their own wallet software.
3. **Trigger:** The moment the attacker queries the balance or tries to spend from one of these addresses, it appears on the public blockchain.
4. **Alert:** A blockchain monitoring service detects this activity and sends you an alert.

## Setting Up Watchlists

To monitor your honeypot addresses, you should import them into "Watchlists" on popular block explorers.

### 1. Export Honeypot Addresses
First, use the CLI to get a list of all public addresses generated in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing all addresses indexed by chain.

### 2. Import to Block Explorers
Register for an account on the following services and add your honeypot addresses to their "Address Watchlist" or "Alerts" feature:

- **Ethereum (and EVM chains):** [Etherscan](https://etherscan.io/)
- **Bitcoin:** [BlockCypher](https://www.blockcypher.com/) or [Blockchain.com](https://www.blockchain.com/)
- **Solana:** [Solscan](https://solscan.io/)
- **XRP:** [Bithomp](https://bithomp.com/)

### 3. Configure Alerts
Set the alerts to trigger on:
- **Incoming Transactions:** (Rare, since these are bait addresses).
- **Outgoing Transactions:** (Indicates an attempt to move funds).
- **Address Activity:** Any interaction with the address.

## Security Considerations

- **No Real Funds:** Never deposit real cryptocurrency into honeypot addresses.
- **Bait Strategy:** Some defenders choose to put a very small amount of "dust" (e.g., $1-5 worth of ETH) in the honeypot to further entice attackers and ensure activity is recorded on-chain, but this is optional and carries risk.
- **Manifest Privacy:** Keep your `manifest.json` encrypted and secure. It contains the private keys that correspond to these addresses.
