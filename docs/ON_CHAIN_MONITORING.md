# On-Chain Monitoring Guide

Layer 4 of the detection strategy involves monitoring the generated honeypot addresses for any activity on the public blockchain. This confirms that an attacker has not only stolen the files but has successfully imported them into a wallet.

## 1. Exporting Addresses

Use the CLI to export all generated addresses to a JSON file:

```bash
honeypot-deployer export-addresses --manifest ./manifest.json --output ./monitored-addresses.json
```

## 2. Setting Up Watchlists

Once you have the list of addresses, you should add them to watchlists on popular block explorers to receive real-time notifications.

### Ethereum / EVM (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Go to **Account** -> **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Enable **Notify on Incoming & Outgoing Txns**.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) or [Solana Explorer](https://explorer.solana.com/).
2. You can use their API or third-party services like **Helius** to set up webhooks for specific addresses.

### Bitcoin (Blockchain.com, Mempool.space)
1. Many explorers allow you to "Follow" an address.
2. For professional monitoring, consider using a dedicated node with `bitcoind` and the `watchonly` wallet feature.

---

## 3. Integrating with Wazuh

The `honeypot_rules.xml` file includes rules for `source: chain-monitor`. To trigger these alerts, you can use a small script that polls these explorers or uses webhooks to write logs to a file monitored by the Wazuh agent.

### Example log format (JSON):
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc..."
}
```

By integrating these on-chain events, you achieve a closed-loop detection system that tracks the attacker from initial access to the final attempt at monetizing the stolen assets.
