# On-Chain Monitoring Guide

This guide explains how to establish and track honeypot addresses on various blockchains to detect when an attacker imports and uses stolen keys.

## Overview

The `honeypot-deployer` generates randomized, non-funded cryptocurrency keys. While Wazuh detects the *access* to these keys on your local system, **On-Chain Monitoring** detects the *use* of these keys.

When an attacker steals a wallet file, their first step is usually to import it into their own wallet software to check the balance. By monitoring these addresses on public blockchains, you can receive alerts even if the attacker is operating from a completely different network.

## Monitoring Strategies

### 1. Manual Tracking (Small Scale)
For a few honeypots, you can use public block explorers with "Watchlist" or "Alert" features:
- **Ethereum/EVM:** [Etherscan](https://etherscan.io/) (Watch List)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer)
- **Solana:** [Solscan](https://solscan.io/)

### 2. Automated Monitoring (Recommended)
For production environments, use the `chain-monitor-addresses.json` exported by the CLI with an automated script or service.

```bash
# Export addresses from your manifest
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./monitored-addresses.json
```

## Setup by Chain

### Ethereum & EVM (ETH, BSC, Polygon)
Use the `address` field from the manifest.
- **What to watch:** `Balance` (native token), `Token Transfers` (ERC-20), and `Contract Executions`.
- **Note:** Attackers often check balances via `eth_getBalance` RPC calls. High-fidelity monitoring should look for any transaction where the honeypot address is the `FROM` field.

### Bitcoin (BTC)
Use the `address` field.
- **What to watch:** Any new transaction appearing in the mempool or confirmed in a block involving the address.
- **Format:** The honeypot generates standard SegWit (Bech32) addresses starting with `bc1q`.

### Solana (SOL)
Use the `address` field.
- **What to watch:** `Account Subscriptions` via Solana RPC nodes.
- **Events:** Look for `transfer` instructions or `Signatures` related to the account.

## Integrating with Wazuh

The Wazuh Manager can receive alerts from a chain monitoring script. The custom rules (100530-100533) are designed to process JSON logs from such a script.

**Expected Log Format:**
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc123...",
  "description": "Outbound transfer detected from honeypot address"
}
```

To integrate:
1. Run your monitoring script (e.g., a Python script using `web3.py`).
2. Have the script write alerts to a local file (e.g., `/var/log/honeypot-chain.log`).
3. Add this file to the Wazuh Manager's `ossec.conf` as a `<localfile>`.

## Security Considerations

- **NEVER** deposit real funds into honeypot addresses.
- If you see a transaction, assume the entire endpoint where that key was stored is **fully compromised**.
- Attackers may "dust" addresses with tiny amounts of crypto to see if they are active. Treat any inbound transaction as a precursor to an outbound one.
