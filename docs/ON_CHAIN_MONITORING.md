# On-Chain Monitoring Guide

Layer 4 of the Crypto Wallet Honeypot detection strategy involves monitoring the public blockchain for any activity related to the generated honeypot addresses. Since these addresses are non-funded, any transaction or balance query indicates that an attacker has successfully stolen and imported the keys.

## 1. Export Honeypot Addresses

First, use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-to-watch.json
```

This will generate a JSON file containing all BTC, ETH, and SOL addresses associated with your honeypots.

## 2. Set Up Watchlists

You can use popular block explorers to receive email or webhook notifications when activity occurs on these addresses.

### Ethereum (ETH) and EVM Chains
1.  Create an account on [Etherscan](https://etherscan.io/).
2.  Go to the **Watch List** section.
3.  Add the exported Ethereum addresses.
4.  Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin (BTC)
1.  Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
2.  Many explorers offer "Address Alerts" or "Watch Only" wallet features.

### Solana (SOL)
1.  Use [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
2.  Register for an account and add addresses to your "Monitor" or "Watchlist".

---

## 3. Integrating with Wazuh

For automated detection, you can use a script that polls these explorers or uses their APIs to feed events back into Wazuh.

### Example: Chain Monitor Integration
The `honeypot_rules.xml` already includes rules for events with `source: chain-monitor`. You can feed JSON logs into the Wazuh manager's log collector:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc123..."
}
```

When Wazuh receives this log, it will trigger **Rule 100530** (Level 15).

---

## 4. Why Monitor On-Chain?

- **Attacker Attribution:** If an attacker moves "funds" to an exchange, it can provide a lead for law enforcement.
- **Verification of Theft:** Confirms that the honeypot trigger was not a false positive and that the attacker actually extracted the keys.
- **Persistence Detection:** Detects if an attacker uses the keys weeks or months after the initial compromise.
