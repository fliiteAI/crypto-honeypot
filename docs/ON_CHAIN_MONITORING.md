# On-Chain Monitoring Guide

On-chain monitoring is the fourth layer of defense in the Crypto Wallet Honeypot system. It allows you to detect if an attacker has successfully exfiltrated a honeypot key and is attempting to use it on the blockchain.

## Why On-Chain Monitoring?
While Wazuh detects the *local* access to the honeyfiles, on-chain monitoring provides visibility into the *attacker's subsequent actions*. If an attacker imports a honeypot key into their own wallet, they will often query the balance or attempt a test transaction. These actions leave a trace on the blockchain.

## How it Works
1. **Generate Artifacts:** Use the `honeypot-deployer generate` command to create your honeypots.
2. **Export Addresses:** Extract the public addresses associated with those honeypots.
3. **Setup Watchlists:** Import these addresses into a blockchain monitoring service.

## 1. Exporting Honeypot Addresses
The `honeypot-deployer` CLI provides a dedicated command to export all public addresses from a deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlists.json
```

This will create a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## 2. Setting Up Watchlists
Once you have the public addresses, you should add them to a monitoring service that can send you alerts (via Email, Slack, Webhook, etc.) when any activity occurs on those addresses.

### Recommended Services:
- **Ethereum (ETH) / EVM:** [Etherscan Watchlist](https://etherscan.io/myaddress)
- **Bitcoin (BTC):** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or various address tracking bots.
- **Solana (SOL):** [Solscan](https://solscan.io/) or [Helius](https://www.helius.dev/) (for developers).
- **XRP:** [XRPScan](https://xrpscan.com/).

### What to Look For:
- **Inbound Transactions:** Even if the attacker sends a small amount of "dust" to the address, it's a sign they are interacting with it.
- **Balance Queries:** Some advanced monitoring services can alert on RPC calls to specific addresses.
- **Outbound Transactions:** If you see an outbound transfer (which should be impossible since the accounts are empty), it means the attacker has deposited funds into the honeypot before trying to move them, or is using it for some other purpose.

## 3. Integrating with Wazuh
While on-chain alerts typically come from external services, you can integrate them back into Wazuh for a centralized view of the incident:

- **Webhooks:** Use a webhook from the monitoring service to send a log to a Wazuh-monitored endpoint.
- **Custom Integration:** Write a small script that polls the monitoring service API and writes logs to `/var/ossec/logs/active-responses.log` or a similar monitored path.

Custom Wazuh Rule ID **100530** is specifically designed to trigger when on-chain activity is detected.
