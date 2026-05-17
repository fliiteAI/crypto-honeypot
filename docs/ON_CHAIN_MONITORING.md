# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) provides a fail-safe detection mechanism. By watching the public addresses of your honeypot wallets, you can detect when an attacker successfully exfiltrates a private key and imports it into their own wallet.

## 1. Exporting Honeypot Addresses

After generating your artifacts, you must export the public addresses to track them.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This command extracts only the public addresses and their corresponding chains from your encrypted manifest.

## 2. Setting Up Watchlists

You can use various blockchain explorers and notification services to monitor these addresses.

### Ethereum & EVM (ETH, BSC, Polygon)
- **Etherscan/BscScan:** Create a free account and add the exported addresses to your "Watch List". You can enable email notifications for any incoming or outgoing transactions.
- **Tenderly:** Use Tenderly's Alerting feature for more advanced monitoring, including internal transactions and contract interactions.

### Bitcoin (BTC)
- **Blockchain.com:** Supports basic address watching and email alerts.
- **Mempool.space:** Useful for monitoring pending transactions in the mempool.

### Solana (SOL)
- **Solscan:** Add addresses to your watchlist after creating an account.
- **Helius:** Use Helius Webhooks for real-time programmatic notifications of Solana address activity.

### Cardano (ADA)
- **Cardanoscan:** Provides address monitoring and transaction tracking.

## 3. What to Watch For

Since these honeypot wallets are **non-funded**, any activity is a critical indicator of compromise:

1. **Balance Queries:** Some advanced monitoring tools can alert on simple balance lookups (though this is rare for public explorers).
2. **Inbound Transactions:** Attackers may send a small amount of "dust" (gas money) to the address to enable them to move other assets they believe are there.
3. **Outbound Transactions:** If you have placed "bait" funds (not recommended for most users), any outbound transaction is 100% confirmation of theft.

## 4. Integration with Wazuh

While on-chain activity happens outside your infrastructure, you can integrate these alerts back into Wazuh:

1. **Webhooks:** Configure your monitoring service (like Helius or Tenderly) to send a webhook to a middleware that logs to a file monitored by the Wazuh Agent.
2. **Custom Decoders:** Create a Wazuh decoder for the webhook logs to trigger a Level 15 alert (Rule ID 100530+).

---

**Warning:** Never deposit real funds into honeypot addresses unless you are an advanced security researcher prepared to lose them for the sake of tracking. The primary value is in detecting the *import* and *probing* of the keys.
