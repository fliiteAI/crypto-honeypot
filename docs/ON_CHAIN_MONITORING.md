# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection. Even if an attacker successfully exfiltrates a private key and bypasses endpoint-level detection, their activity can be tracked once they interact with the blockchain.

## 1. Exporting Honeypot Addresses

First, use the CLI to export the public addresses associated with your deployed honeypots:

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/manifest.json \
  --output ./honeypot-addresses.json
```

## 2. Setting Up Watchlists

You should add these addresses to "Watchlists" on popular block explorers. These services will send you an email or webhook alert whenever an address is queried or involved in a transaction.

### Ethereum & EVM (Etherscan, Poly-scan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** -> **Watch List**.
3. Add your honeypot ETH addresses.
4. Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin (Blockchain.com, Blockcypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/) or [Blockcypher](https://www.blockcypher.com/) to monitor BTC addresses.
2. Many explorers offer API webhooks for real-time monitoring.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use the "Watchlist" feature (requires account) to track your Solana `id.json` addresses.

---

## 3. Interpreting On-Chain Alerts

| Activity | Severity | Likely Cause |
|----------|----------|--------------|
| **Incoming "Dust"** | Low | Automated scanning or random dusting attack. |
| **Balance Query** | Medium | Attacker has imported the key into a wallet and is checking for funds. |
| **Outgoing Transfer** | Critical | Attacker is attempting to move funds (if any were present). This confirms the key is compromised. |

## 4. Automation (Advanced)

For professional SOC environments, you can automate this layer by using blockchain indexing APIs (like Alchemy, QuickNode, or Infura) to script a monitor that feeds directly into Wazuh via the custom log collector.

Example Python snippet for monitoring:
```python
# Pseudo-code for monitoring an address
while True:
    balance = get_balance(honeypot_address)
    if balance > 0:
        log_to_wazuh("CRITICAL: Funds detected on honeypot address!")
    time.sleep(300)
```
