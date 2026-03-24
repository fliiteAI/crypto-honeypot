# On-Chain Monitoring Guide: Tracking Honeypot Addresses

The Crypto Wallet Honeypot system provides a layer of detection on the blockchain itself. By monitoring the public addresses of your honeypots, you can detect when an attacker has stolen and imported the private keys, even if they have bypassed other monitoring layers.

## Exporting Addresses

To get a list of the generated honeypot public addresses for all your monitored chains, use the `honeypot-deployer` CLI:

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./chain-monitor-addresses.json
```

This will create a JSON file containing the public addresses for BTC, ETH, SOL, XRP, and ADA (as applicable).

## Block Explorer Watchlists

The most effective way to monitor these addresses is by adding them to watchlists on popular block explorers. Most explorers offer email or API-based notifications when activity occurs on a watched address.

### Ethereum and EVM-Compatible Chains (Etherscan, BscScan, PolyScan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Add your honeypot ETH addresses.
4. Enable notifications for any incoming or outgoing transaction activity.

### Bitcoin (Blockchain.com, Blockcypher)
- Many Bitcoin block explorers offer address-specific monitoring and notification services.
- Consider using an API service like [BlockCypher](https://www.blockcypher.com/) for automated monitoring.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) to view your Solana `id.json` address.
2. Sign up for a free account to access their monitoring and notification features.

### XRP (XRPScan)
- Use [XRPScan](https://xrpscan.com/) to monitor the public addresses for your generated XRP artifacts.

### Cardano (Cardanoscan)
- Use [Cardanoscan](https://cardanoscan.io/) to track the public addresses associated with your ADA `.skey` signing keys.

## Response Strategy

If you receive an on-chain activity alert for a honeypot address:
1. **Assume Total Compromise:** Treat the endpoint where that honeypot was deployed as fully compromised.
2. **Isolate the Endpoint:** Disconnect the affected system from the network immediately.
3. **Analyze Wazuh Logs:** Review the Wazuh alerts to identify the user account and processes involved in the initial file access.
4. **Identify the Attacker:** Look for network correlation events (Layer 3) to determine if and where the data was exfiltrated.
