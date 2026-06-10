# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect when an attacker has successfully exfiltrated a private key or seed phrase and is attempting to use it on the live blockchain.

## Exporting Honeypot Addresses

To monitor the honeypot addresses, you first need to export them from your deployment manifest.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watch-list.json
```

This command extracts the public addresses for all generated chains (BTC, ETH, SOL, etc.) and saves them in a format suitable for importing into monitoring tools.

## Setting Up Watchlists

Once you have the list of addresses, you should set up alerts on popular block explorers.

### Ethereum & EVM (Etherscan / Polygonscan)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** -> **Watch List**.
3. Click **Add** and enter a honeypot address.
4. Select **Notify on Incoming & Outgoing Txns**.

### Solana (Solscan)
1. Use [Solscan's](https://solscan.io/) monitoring features or a custom tracking tool like [Helius](https://www.helius.dev/) to set up webhooks for address activity.

### Bitcoin
1. Use a block explorer like [Blockchain.com](https://www.blockchain.com/explorer) or set up a local `bitcoind` node with a watch-only wallet to monitor for transactions.

## Integrating with Wazuh

When an external monitor detects activity, it should log a JSON event that can be ingested by Wazuh.

**Example Event Format:**
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc123..."
}
```

If this event is sent to the Wazuh Manager (e.g., via a local log file monitored by the agent), it will trigger **Rule 100530** (On-chain activity detected).

## Why This is Effective

Many attackers use automated scripts to "drain" wallets as soon as they are imported. By monitoring these addresses on-chain, you can confirm a successful exfiltration even if the attacker successfully evaded your endpoint-level network monitoring.
