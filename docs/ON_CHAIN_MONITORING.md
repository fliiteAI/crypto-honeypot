# On-Chain Monitoring Strategy: Crypto Wallet Honeypot

The on-chain monitoring strategy (Layer 4) provides a final safety net for detecting compromises. Even if an attacker manages to bypass local endpoint protections, the moment they import a stolen honeypot key into a wallet and query its balance or attempt a transaction, we can detect the activity on the blockchain.

## Strategy Overview

1. **Address Generation:** Use the `honeypot-deployer` CLI to generate randomized wallet artifacts for multiple chains.
2. **Address Export:** Export the generated public addresses using the `export-addresses` command.
3. **Watchlist Setup:** Import these addresses into a blockchain monitoring service (e.g., Etherscan, Solscan, BTC.com) to receive notifications of any activity.
4. **Wazuh Integration:** (Optional) Configure the monitoring service to send alerts to the Wazuh Manager via a webhook or log integration.

---

## 1. Export Honeypot Addresses

After generating your honeypot artifacts, you can export the public addresses associated with them:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This JSON file contains the public addresses for each chain (BTC, ETH, SOL, etc.) that you should monitor.

## 2. Setting Up Watchlists

### Ethereum (and EVM-compatible chains)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **Account** -> **Watch List**.
3. Use the **Add** button to import your exported ETH addresses.
4. Enable **Notify on Incoming/Outgoing Tx** to receive email alerts.
5. Repeat for other EVM chains (e.g., BSC, Polygon) if you've deployed assets there.

### Solana
1. Use a service like [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2. Create an account and add your exported SOL addresses to your watchlist.
3. Configure email or Telegram notifications for transaction activity.

### Bitcoin
1. Use [BTC.com](https://explorer.btc.com/) or another Bitcoin explorer with watchlist support.
2. Import your exported BTC addresses and enable notifications.

---

## 3. Interpreting Activity

| Activity Type | Description | Severity |
|---------------|-------------|----------|
| **Balance Query** | Attacker has imported the key and is checking the balance. | **High** |
| **Inbound Tx** | (Unlikely) Small amount sent to the address (e.g., dusting attack). | **Medium** |
| **Outbound Tx** | Attacker is attempting to sweep funds. | **Critical** |
| **Token Approval** | Attacker is interacting with a DeFi drainer contract. | **Critical** |

---

## Security Best Practices

- **Zero Funding:** Never deposit real funds into honeypot addresses. They are intended only to track attacker activity.
- **Privacy:** Use an anonymous email address for watchlist notifications to avoid linking your main identity to your honeypot network.
- **Monitoring Only:** Use these watchlists to trigger alerts, not for automated defensive actions on the blockchain, as you don't control the attacker's wallet.
