# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect if an attacker has successfully exfiltrated a private key and is now using it on the blockchain.

## Overview

When you generate honeypot artifacts using the `honeypot-deployer`, the system creates valid (but empty) cryptocurrency addresses. By adding these addresses to a "watchlist" on a block explorer, you can receive alerts even after the attacker has left your network.

## Setup Instructions

### 1. Export Honeypot Addresses
Use the CLI to export all generated public addresses into a JSON format:

```bash
honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./watchlist.json
```

### 2. Configure Watchlists
Import the addresses from `watchlist.json` into the following services based on the chain:

#### Ethereum / EVM (ETH, BSC, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) / [BscScan](https://bscscan.com/)
- **Feature:** "Watch List" (requires a free account).
- **Setup:** Add the exported Ethereum addresses and enable notification for "All Transactions" (Incoming & Outgoing).

#### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/)
- **Feature:** "Account Tracking" or use a telegram bot like @SolanaTrackBot.
- **Setup:** Monitor the exported Solana public keys.

#### Bitcoin (BTC)
- **Service:** [Blockchain.com Explorer](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
- **Setup:** Create a watch-only wallet or use a notification service that supports Bitcoin addresses.

### 3. Integrating with Wazuh
The `honeypot_rules.xml` includes rules (IDs 100530-100533) designed to process logs from a chain-monitoring service. If you have a script that polls block explorer APIs, it should format logs as follows for Wazuh to trigger an alert:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "activity_type": "outbound_transfer",
  "chain": "eth",
  "address": "0x123abc...",
  "txid": "0xdef456...",
  "amount": "0.01"
}
```

## What to Look For

- **Balance Queries:** Some automated tools will check the balance of a stolen key immediately upon import.
- **Test Transactions:** Small incoming transactions followed by an outgoing sweep are a common sign of an attacker testing a stolen key.
- **Token Approvals:** Attackers may use "drainer" scripts that request token approvals (ERC-20/SPL) to steal other assets.

## Security Warning
**NEVER deposit real funds into these honeypot addresses.** The private keys are stored in the `manifest.json` and are considered "burnt" from a security perspective once deployed as bait.
