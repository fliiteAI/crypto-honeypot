# On-Chain Monitoring Guide

This guide explains how to monitor the generated honeypot addresses for on-chain activity. This provides a fourth layer of detection: identifying when an attacker has successfully imported and is attempting to use the stolen keys.

## 1. Export Honeypot Addresses

After generating your artifacts, you can export all public addresses to a JSON file for easy import into monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./bait-addresses.json
```

The output file will contain a list of addresses for each supported chain:
- **Bitcoin (BTC)**
- **Ethereum (ETH)**
- **Solana (SOL)**
- **XRP (Ripple)**
- **Cardano (ADA)**

## 2. Setting up Block Explorer Watchlists

The most effective way to monitor these addresses is by using "Watchlist" or "Address Alert" features provided by major block explorers.

### Ethereum & EVM Chains (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** -> **Watch List**.
3. Click **Add** and paste an ETH address from your `bait-addresses.json`.
4. Select **Notify on Incoming & Outgoing Txns**.
5. (Recommended) Enable **Track ERC-20 Token Transfers** to detect if the attacker checks for non-native assets.

### Solana (Solscan / Solana Tracker)
1. Use [Solscan](https://solscan.io/) or [Solana Tracker](https://www.solanatracker.io/).
2. Set up alerts for the SOL addresses in your manifest.
3. Monitor for any `Transfer` or `Account Creation` instructions.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) to set up email notifications for BTC address activity.

### XRP Ledger (XRPScan)
1. Monitor XRP addresses on [XRPScan](https://xrpscan.com/).
2. Look for `Payment` transactions or `AccountSet` modifications.

## 3. SIEM Integration

While block explorers provide email alerts, you can correlate this activity in Wazuh if you have a log source for these alerts.

### Rule 100530: On-chain Activity
When you receive an email alert from a block explorer:
1. Forward the alert to your centralized logging or Wazuh Manager.
2. Use the `honeypot_rules.xml` (Rule 100530-100532) to fire high-severity alerts.

## 4. Why Monitor On-Chain?

- **Attribution:** On-chain movements can sometimes be traced back to exchange deposit addresses, helping identify the attacker.
- **Confirmation:** It confirms that the "data" stolen was indeed a private key and that the attacker is sophisticated enough to use it.
- **Beyond the Perimeter:** Detection works even if the attacker accesses the wallet files from a machine not monitored by Wazuh (e.g., via an unmonitored backup or network share).

---
**Note:** The honeypot keys are generated locally and never transmitted. The addresses are public, but the private keys remain in your manifest and on the deployed endpoints.
