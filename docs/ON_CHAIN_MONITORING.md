# On-Chain Monitoring Guide

The final layer of the Crypto Wallet Honeypot detection strategy is monitoring the blockchain for activity related to the generated honeypot addresses.

## Concept

When you run `honeypot-deployer generate`, the tool creates real private/public key pairs. While the wallets are deployed with zero funds, an attacker who steals these keys doesn't know that initially. They will likely:
1. Import the keys into a wallet (MetaMask, Phantom, etc.).
2. Query the balance of the address.
3. Attempt to send a small amount of "gas" to the address to withdraw assets.

Any of these actions result in on-chain activity that can be detected independently of your local infrastructure.

## Step 1: Export Honeypot Addresses

Use the CLI to export all generated public addresses to a JSON file:

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./watch-list.json
```

## Step 2: Set Up Watchlists

You can use various free and paid services to monitor these addresses.

### Etherscan / Solscan / Blockchain.com
Most major block explorers allow you to create "Watchlists" or "Address Alerts":
1. Create an account on the explorer (e.g., [Etherscan](https://etherscan.io)).
2. Navigate to the **Watchlist** section.
3. Add the addresses from your `watch-list.json`.
4. Configure email or webhook notifications for any "Incoming" or "Outgoing" transactions.

### Open-Source Monitoring (Self-Hosted)
For a more automated and private approach, you can use tools like:
- **Tenderly Webhooks:** Monitor EVM-compatible chains (ETH, BSC, Polygon).
- **Helius:** Best for Solana (SOL) address monitoring.
- **Custom Scripts:** Use the `watch-list.json` with a simple Python script using `web3.py` or `solana-py` to poll balances.

## Step 3: Responding to On-Chain Alerts

An on-chain alert is a **Critical Severity** event. It means:
1. An attacker has successfully bypassed your host-level security.
2. They have successfully exfiltrated data from your environment.
3. They are actively attempting to monetize the theft.

**Recommended Actions:**
- Immediately identify the endpoint associated with the compromised address (check the `manifest.json` or Wazuh logs).
- Isolate the affected host from the network.
- Initiate a full forensic investigation and credential rotation.
