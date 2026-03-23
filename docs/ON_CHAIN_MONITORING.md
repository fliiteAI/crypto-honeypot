# On-Chain Monitoring Guide: Tracking Honeypot Addresses

This guide provides instructions for monitoring the generated honeypot addresses on-chain to detect the final stages of a credential theft attack.

## Why Monitor On-Chain?

While internal Wazuh alerts provide immediate notice of file access, on-chain activity is a "high-fidelity" signal that the stolen data has been successfully imported by an attacker.

Monitoring for activity on these addresses provides:
1. **Confirmation of Breach:** If an attacker imports a honeypot key, you *know* the system was compromised.
2. **Attacker Intelligence:** Monitoring where stolen funds go (if any were deposited as bait) can help identify the attacker's infrastructure.
3. **Cross-Chain Visibility:** Even if you only monitor internal logs for one system, an attacker might import keys from multiple systems into a single wallet.

---

## Setting Up Watchlists

After generating your honeypot artifacts, use the `honeypot-deployer export-addresses` command to get a list of addresses to monitor:

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./watchlist.json
```

### 1. Bitcoin (BTC)
Use [Blockcypher](https://www.blockcypher.com/) or [Mempool.space](https://mempool.space/) to set up address alerts. Many block explorers offer API-based or email-based notifications for address activity.

### 2. Ethereum (ETH) & EVM Chains
Use [Etherscan](https://etherscan.io/) "Watch List" feature to receive email alerts for any incoming or outgoing transactions on your honeypot addresses. This works for many EVM-compatible chains (BSC, Polygon, Optimism, etc.) using their respective explorers.

### 3. Solana (SOL)
Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/) to monitor for any token transfers or account changes.

---

## Monitoring for Balance Queries

Sophisticated attackers use automated scripts to "sweep" stolen keys. You can often see these balance queries even before a transaction occurs if you use a provider that tracks API calls to specific addresses.

### Services for Monitoring
- **Etherscan APIs:** Track address activity and token balances.
- **Alchemy / Infura:** Monitor for `eth_getBalance` calls on your honeypot addresses.
- **Tenderly:** Set up real-time alerts for any on-chain interaction.

---

## Action Plan: What to Do if an Address is Accessed

1. **Immediately Isolate:** If a honeypot address shows activity, assume the system where the artifact was deployed is fully compromised.
2. **Review Wazuh Logs:** Correlate the on-chain activity timestamp with internal Wazuh FIM and audit logs.
3. **Trigger Active Response:** Manually or automatically trigger a forensic snapshot of the compromised endpoint.
4. **Assume Credential Theft:** If one wallet was stolen, assume all credentials on that system are compromised.
