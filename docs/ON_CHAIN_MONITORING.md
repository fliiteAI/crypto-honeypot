# On-Chain Monitoring Guide

Once you have deployed your honeypot artifacts, the final layer of detection is monitoring the public addresses associated with those bait keys on the blockchain.

## Why Monitor On-Chain?

If an attacker successfully exfiltrates your honeypot keys, they will likely import them into a wallet or use an automated script to check for balances. By monitoring these addresses, you can detect a compromise even if your internal network monitoring was bypassed.

## Step 1: Export Honeypot Addresses

Use the `honeypot-deployer` CLI to export all generated public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlist.json
```

This will create a JSON file containing the addresses for all chains (BTC, ETH, SOL, etc.).

## Step 2: Set Up Watchlists

You can monitor these addresses using several methods:

### Method A: Block Explorer Watchlists (Easiest)
Most popular block explorers offer free "Watchlist" or "Address Alert" services that send email notifications when activity is detected.

- **Ethereum/EVM:** [Etherscan.io](https://etherscan.io/myaddress)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Blockstream.info](https://blockstream.info/)
- **Solana:** [Solscan.io](https://solscan.io/)
- **Cardano:** [Cardanoscan.io](https://cardanoscan.io/)

### Method B: Self-Hosted Monitoring (Advanced)
For high-security environments, you can run your own monitoring script that polls a node or an API (like Alchemy, Infura, or QuickNode) and sends logs directly to your Wazuh Manager.

## Step 3: Integrate with Wazuh

When an on-chain event is detected, it should be sent to the Wazuh Manager as a JSON log. The `honeypot_rules.xml` already includes rules for Layer 4 detection.

**Example Log Format:**
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "activity_type": "outbound_transfer",
  "chain": "ethereum",
  "address": "0x1234...5678",
  "txid": "0xabc...def",
  "amount": "0.01 ETH"
}
```

## Recommended Alerts to Watch For

1. **Balance Queries:** Small "test" transactions often precede a full drain.
2. **Token Approvals:** If your honeypot is targeted by a DeFi drainer, you will see an `Approve` transaction.
3. **Outbound Transfers:** This is a critical indicator that the attacker is actively using the stolen keys.

---

**CRITICAL SECURITY NOTE:**
**NEVER** deposit real funds into your honeypot addresses. The goal is to detect access, not to provide a "bounty" for the attacker.
