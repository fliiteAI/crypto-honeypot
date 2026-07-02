# On-Chain Monitoring Guide

On-chain monitoring is Layer 4 of the Crypto Wallet Honeypot detection strategy. It allows you to track if an attacker has successfully imported and is attempting to use the stolen keys.

## 1. Exporting Honeypot Addresses

First, export the public addresses from your encrypted manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

The output will be a JSON file mapping chains to their respective honeypot addresses:
```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["..."]
}
```

## 2. Setting Up Watchlists

Since the honeypot keys are non-funded, you don't need to run a full node to monitor them. Use the following free services to receive alerts:

### Ethereum & EVM (Etherscan / Polygonscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** > **Watch List**.
3. Click **Add** and paste your honeypot ETH address.
4. Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin (Blockchain.com / BlockCypher)
1. Use services like [BlockCypher](https://www.blockcypher.com/) or [Mempool.space](https://mempool.space/) to set up webhooks for specific addresses.
2. Many mobile wallets (like BlueWallet or Sentinel) allow you to add "Read-Only" or "Watch-only" addresses and will send push notifications on activity.

### Solana (Solscan)
1. Visit [Solscan.io](https://solscan.io/).
2. Use their "Monitor" feature or set up a free account to track specific account activity.

---

## 3. Interpreting Activity

| Event Type | Meaning | Action Required |
|------------|---------|-----------------|
| **Incoming "Dust"** | A random bot sent a tiny amount of crypto. | Low severity, usually automated. |
| **Balance Query** | Attacker checked the address on a block explorer. | High severity. They are evaluating the "loot". |
| **Outbound Transaction** | Attacker tried to move funds (requires them to send gas first). | **Critical**. Active theft attempt. |
| **Token Approval** | Attacker interacting with a malicious contract. | **Critical**. DeFi drainer signature. |

## 4. Integration with Wazuh

If you have a script that polls these block explorers or receives webhooks, you can forward those events to the Wazuh Manager as JSON logs. The custom rules in `honeypot_rules.xml` (IDs 100530-100539) will automatically parse these and fire Layer 4 alerts.

Example JSON log format for Wazuh:
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x123...",
  "activity_type": "outbound_transfer"
}
```
