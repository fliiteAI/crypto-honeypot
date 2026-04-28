# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection. By tracking the public addresses of your honeypot wallets, you can detect when an attacker has successfully exfiltrated a private key and imported it into a wallet or service.

## Exporting Addresses

First, use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-for-monitoring.json
```

## Setting Up Watchlists

Once you have the list of addresses, you should add them to watchlists on the relevant block explorers for each chain.

### 1. Ethereum (and EVM Chains)
- **Tool:** [Etherscan Watch List](https://etherscan.io/myaddress)
- **Setup:** Create a free account, go to "Watch List", and add your honeypot ETH addresses.
- **Alerts:** Enable email or API notifications for "All Transactions" (Incoming & Outgoing).

### 2. Bitcoin
- **Tool:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:** Many Bitcoin explorers allow you to "Follow" or "Watch" an address.
- **Advanced:** Consider using a self-hosted tool like [BTCPay Server](https://btcpayserver.org/) to monitor a large number of addresses via an xPub/Watch-only wallet.

### 3. Solana
- **Tool:** [Solscan](https://solscan.io/)
- **Setup:** Solscan provides account-based monitoring and alert features for tracked addresses.

### 4. Ripple (XRP)
- **Tool:** [XRP Scan](https://xrpscan.com/)
- **Setup:** Monitor the account status and transaction history for the generated XRP addresses.

---

## What to Look For

Since these honeypot addresses are **non-funded**, any activity is highly suspicious:

1. **Dust Transactions:** Attackers or bots may send a tiny amount of crypto (dust) to the address to see if it's active or to test their ability to spend from it.
2. **Balance Queries:** While not visible on-chain as a transaction, many wallet apps will query the balance of an imported key.
3. **Outbound Transfers:** If you (accidentally) left any funds or if someone sent dust that is then moved, it's a 100% confirmed compromise.

## Integrating with Wazuh

For advanced users, you can use the block explorer APIs (like Etherscan API) to pull transaction data and ingest it into Wazuh as a log source.

1. **Script:** Write a simple Python script to poll the API for your watched addresses.
2. **Log:** Output any found transactions to a JSON file.
3. **Wazuh:** Configure a Wazuh log collector to monitor that JSON file.
4. **Rules:** Use Rule ID `100530` (On-chain activity) to fire alerts.
