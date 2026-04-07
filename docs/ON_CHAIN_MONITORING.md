# On-Chain Monitoring: Tracking Bait Addresses

On-chain monitoring is the final layer of defense. It detects when an attacker successfully exfiltrates honeypot keys and interacts with them on the public blockchain.

## 1. Exporting Honeypot Addresses

After generating your honeypot artifacts, you must export the public addresses to track them.

```bash
# Export all public addresses from the manifest
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watchlist-addresses.json
```

The output file will contain the public addresses for each chain (BTC, ETH, SOL, XRP, ADA, etc.) that you should monitor.

## 2. Setting Up Watchlists

You should add these addresses to external "Watchlist" services to receive notifications of any activity.

### Block Explorer Watchlists (Recommended)

| Chain | Service | Monitoring Method |
|-------|---------|-------------------|
| **BTC** | Blockchain.com / BlockCypher | Wallet Watchlists (Email/Webhook) |
| **ETH/EVM** | Etherscan | "My Watchlist" (Email/API) |
| **SOL** | Solscan / SolanaFM | "Address Tracking" (Webhooks/API) |
| **XRP** | XRP Ledger Explorer | XRPL Account Notifications |

### Automated Monitoring

For a more integrated experience, you can use the `watchlist-addresses.json` as a source for a custom script that periodically checks the balances and transaction history using public APIs (e.g., Infura, Alchemy, Helius).

## 3. Feeding Events to Wazuh

To complete the loop, you should feed on-chain activity events back into Wazuh.

### Integration Steps

1. **Format Logs:** Ensure your monitoring script outputs events in JSON format.
2. **Log Collection:** Configure the Wazuh agent to collect these JSON logs:
   ```xml
   <localfile>
     <location>/path/to/chain-monitor.log</location>
     <log_format>json</log_format>
   </localfile>
   ```
3. **Alerting:** The Wazuh Manager's custom rule set (Rule IDs 100530-100533) will automatically process these logs and trigger high-severity (Level 15) alerts.

## 4. Key Indicators of Attack

- **Balance Query:** The attacker is checking if the "stolen" wallet contains funds.
- **Inbound Transfer (Dust):** The attacker is "dusting" the wallet to test if it's active.
- **Outbound Transfer:** The attacker is attempting to drain the wallet (highest severity).
- **Contract Approval:** The attacker is interacting with a DeFi protocol to approve token spending (DEX/Drainer behavior).
