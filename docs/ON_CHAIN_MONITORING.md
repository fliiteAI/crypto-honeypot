# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final and most definitive layer of detection. It ensures that even if an attacker manages to exfiltrate keys without being detected by endpoint or network security, their subsequent actions will still trigger an alert.

## How It Works

1.  **Generate Artifacts:** Use `honeypot-deployer generate` to create unique, trackable wallet files.
2.  **Export Addresses:** Use the `export-addresses` command to retrieve the public addresses associated with those artifacts.
3.  **Setup Watchlists:** Import these addresses into external block explorer monitoring services.
4.  **Receive Alerts:** When the attacker imports the keys and interacts with the blockchain, you receive a notification.

## 1. Exporting Honeypot Addresses

After generating your honeypot artifacts, run the following command to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing the public addresses for all generated chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Watchlists

Once you have the addresses, you should add them to watchlists on popular block explorers. Most services offer free email or webhook alerts for a limited number of addresses.

### Ethereum & EVM Chains (ETH, BSC, Polygon)
- **Service:** [Etherscan](https://etherscan.io/) (and its variants like BscScan, PolygonScan)
- **Setup:** Create a free account, go to the "Watch List" section, and add your honeypot addresses. Enable "Email Notification" for any incoming or outgoing transactions.

### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/)
- **Setup:** Use their API or web interface to monitor for any transaction activity involving your honeypot addresses.

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/)
- **Setup:** Use the "Account Watch" feature to receive alerts for any activity on the Solana honeypot addresses.

## 3. Integrating with Wazuh

For advanced users, you can use webhooks from these services to send alerts back to your Wazuh Manager. This allows you to centralize all honeypot alerts (from endpoint access to on-chain theft) in one dashboard.

1.  **Configure Webhook:** Set up the block explorer to send a POST request to a custom endpoint when activity is detected.
2.  **Wazuh Log Collector:** Use a simple script to receive these webhooks and write them to a log file monitored by Wazuh.
3.  **Wazuh Rules:** The system includes pre-defined rules (ID 100530-100533) that will trigger high-severity alerts when these logs are processed.

## Security Warning

**NEVER deposit real funds into honeypot addresses.** The private keys are stored in the deployment manifest and are considered "compromised" by design. The goal is to detect the attacker's interest in the wallet, not to provide them with actual assets.
