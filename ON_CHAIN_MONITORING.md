# On-Chain Monitoring Guide

The Crypto Wallet Honeypot provides defense-in-depth by allowing you to track activity even *after* an attacker has successfully exfiltrated a wallet. By monitoring the public addresses associated with your honeypots, you can receive alerts when an attacker imports the stolen keys and attempts to move funds or query balances.

## How it Works

1. **Generation:** When you run `honeypot-deployer generate`, the tool creates valid public/private key pairs.
2. **Export:** Use `honeypot-deployer export-addresses` to get a list of the public addresses.
3. **Watchlist:** Import these addresses into a blockchain monitoring service.
4. **Alerting:** When activity occurs on these addresses (e.g., a small "dust" transaction or an attempted transfer), the service notifies you, providing definitive proof of compromise.

## Tracking by Chain

### Ethereum & EVM (BSC, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) / [Polygonscan](https://polygonscan.com/)
- **Setup:**
  1. Create a free account.
  2. Navigate to **Watch List**.
  3. Add the honeypot addresses exported from the manifest.
  4. Enable **Notify on Incoming & Outgoing Txns**.

### Solana
- **Service:** [Solscan](https://solscan.io/) or [Helius](https://www.helius.dev/)
- **Setup:**
  1. Use Solscan's "Track Address" feature or Helius Webhooks for real-time programmatic alerts.
  2. Monitor for any `Transfer` or `Account Update` instructions.

### Bitcoin
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Setup:**
  1. Most explorers offer "Address Watch" or "Email Alerts".
  2. For more advanced setups, use a self-hosted `bitcoind` with `watchonly` descriptors.

---

## Using the CLI for Monitoring

To get all addresses for your watchlist:

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./watchlist.json
```

This generates a structured JSON file:

```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["..."]
}
```

## Responding to On-Chain Alerts

An on-chain alert on a honeypot address is a **critical severity** event. It indicates that:
1. An attacker has successfully accessed your filesystem.
2. They have exfiltrated the wallet/key data.
3. They have successfully decrypted (if applicable) and imported the key into a wallet software.

**Recommended Actions:**
- Immediately isolate the host(s) where that specific honeypot was deployed.
- Check Wazuh alerts for that timeframe to identify the source process and user.
- Begin full incident response and forensic analysis on the compromised endpoint.
