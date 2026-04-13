# On-Chain Monitoring Guide

The fourth layer of the Crypto Wallet Honeypot detection strategy is **On-Chain Monitoring**. This involves tracking the public addresses associated with your honeypot artifacts to detect when an attacker imports the stolen keys and interacts with the blockchain.

## Why On-Chain Monitoring?

- **External Validation:** Confirms that the files were not just accessed, but the keys were actually compromised and used.
- **Attacker Attribution:** On-chain movements can sometimes be traced back to exchanges or known attacker infrastructure.
- **Last Resort:** Provides visibility even if the attacker manages to bypass endpoint-level detections or exfiltrate data via covert channels.

## How to Set Up On-Chain Monitoring

### 1. Export Honeypot Addresses
Use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing the public addresses for all generated chains (BTC, ETH, SOL, etc.).

### 2. Configure Watchlists
Import these addresses into monitoring services for each respective blockchain.

#### Ethereum and EVM Chains
- **Etherscan Watchlist:** Create an account on [Etherscan](https://etherscan.io/) and add your honeypot addresses to the "Watch List". Enable email notifications for any incoming or outgoing transactions.
- **Tenderly:** Use [Tenderly](https://tenderly.co/) for more advanced real-time alerts and transaction simulation.

#### Bitcoin
- **Blockchain.com Explorer:** Use the wallet/address tracking features.
- **Self-Hosted:** Use `bitcoin-cli` with `importaddress` (watch-only) and `listreceivedbyaddress` to monitor activity locally.

#### Solana
- **Solscan:** Use the tracking features on [Solscan](https://solscan.io/).
- **Helius:** Use [Helius Webhooks](https://www.helius.dev/) for real-time Solana transaction monitoring.

### 3. Integration with Wazuh (Advanced)
You can integrate on-chain alerts back into Wazuh by using a custom integration or a script that polls block explorer APIs and writes to a log file monitored by the Wazuh agent.

## Best Practices

- **Never Deposit Real Funds:** The honeypot addresses are designed to be empty. Any balance appearing (e.g., from an attacker testing the wallet with a small deposit) is a high-fidelity indicator of compromise.
- **Monitor Multiple Chains:** Ensure you are monitoring all chains for which you have deployed artifacts.
- **Use Webhooks for Speed:** For time-sensitive alerts, use services that support Webhooks to trigger immediate incident response actions.
