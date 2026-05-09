# On-Chain Monitoring Guide

The fourth layer of our detection strategy is on-chain monitoring. Even if an attacker manages to bypass host-based detections, their activity on the blockchain can still be tracked using the public addresses associated with our honeypot private keys.

## Why Monitor On-Chain?

1. **Confirmation of Exfiltration:** If an address you've never used suddenly shows activity, you know with 100% certainty that the private key has been compromised.
2. **Attacker attribution:** Sometimes attackers will consolidate stolen funds into their own wallets, providing potential leads for law enforcement.
3. **Defense-in-Depth:** It provides a safety net if host-based agents are disabled or bypassed by sophisticated malware.

---

## Step 1: Export Honeypot Addresses

First, use the `honeypot-deployer` CLI to export the public addresses from your manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will generate a JSON file containing the public addresses for all generated chains (BTC, ETH, SOL, etc.).

---

## Step 2: Set Up Watchlists

Import the exported addresses into various block explorer "Watchlist" or "Address Alert" services. Most major explorers offer this for free (registration required).

### Recommended Explorers

| Chain | Recommended Explorer | Feature to Use |
|-------|----------------------|----------------|
| **Bitcoin** | [Blockchain.com](https://blockchain.com) | Address Watchlist / Email Alerts |
| **Ethereum / EVM** | [Etherscan](https://etherscan.io) | Watch List |
| **Solana** | [Solscan](https://solscan.io) | My Watchlist |
| **XRP** | [XRPScan](https://xrpscan.com) | Alerts |
| **Cardano** | [Cardanoscan](https://cardanoscan.io) | Address Tracking |

### Configuration Tips

1. **Email Alerts:** Configure the explorer to send an immediate email alert when any transaction (inbound or outbound) is detected.
2. **Watch for Balance Checks:** While some explorers only alert on transactions, others can alert on balance queries or API calls.
3. **No-Funds Rule:** Remember, these addresses should **never** have real funds. Any balance appearing is likely a test by the attacker or a mistake.

---

## Step 3: Integrating with Wazuh

For advanced users, you can use the Wazuh `integration` module to periodically poll block explorer APIs for the status of your honeypot addresses.

1. **Custom Script:** Write a small script to query the explorer API (e.g., Etherscan API).
2. **Wazuh Integration:** Configure the script as a custom integration in the Wazuh Manager's `ossec.conf`.
3. **Alerting:** Create a Wazuh rule (ID 100530) to fire a high-severity alert when the script detects activity.

---

## Summary of Monitoring Principle

| Activity | Severity | Action |
|----------|----------|--------|
| **Host-based access** | High (Level 12) | Investigate endpoint, isolate host. |
| **On-chain activity** | Critical (Level 15) | Confirm exfiltration, trace destination of funds. |
