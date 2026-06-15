# On-Chain Monitoring Guide

Once you have deployed your honeypot, the final layer of detection is monitoring the blockchain for any activity related to the generated addresses.

## Exporting Honeypot Addresses

Use the CLI to export the public addresses associated with your deployment. This creates a JSON file that can be easily imported into monitoring tools.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

## Setting Up Watchlists

We recommend adding the exported addresses to the following block explorer watchlist services for real-time email/webhook alerts:

### Ethereum / EVM (Mainnet, Base, Polygon)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Go to **Account** -> **Watch List**.
3. Import your addresses.
4. Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin
1. Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
2. Alternatively, set up a lightweight `bitcoind` node with `watchonly` descriptors.

### Solana
1. Create an account on [Solscan](https://solscan.io/).
2. Use the **My Watchlist** feature to add your SOL addresses.

## Automated Alerts via Wazuh

If you have a script that polls these explorers or uses webhooks, you can feed those events back into Wazuh.

1. Configure your monitoring script to log events to a local file.
2. Add that file as a `localfile` source in the Wazuh Agent's `ossec.conf`.
3. Use the custom rules (Rule IDs `100530` - `100533`) to trigger alerts in the Wazuh Dashboard.

Example log format for `chain-monitor`:
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x123...", "activity_type": "outbound_transfer"}
```
