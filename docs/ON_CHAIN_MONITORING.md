# On-Chain Monitoring Guide

On-chain monitoring is the fourth and highest-fidelity layer of the Crypto Wallet Honeypot system. It allows you to detect when an attacker has successfully exfiltrated a honeypot key and imported it into their own wallet software.

## Concept

When you generate honeypot artifacts, the `honeypot-deployer` creates valid (but non-funded) private keys and their corresponding public addresses. By monitoring these public addresses on their respective blockchains, we can detect:
1.  **Reconnaissance:** Attacker checking the balance of the stolen address.
2.  **Import Verification:** Attacker sending a tiny amount of dust to the address to verify control.
3.  **Theft Attempts:** Attacker attempting to spend from the address (which will fail if non-funded, but the *attempt* is the signal).

---

## 1. Exporting Addresses

The first step is to extract the public addresses from your deployment manifest. Use the `export-addresses` command:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

This will create a JSON file organized by chain:
```json
{
  "btc": ["bc1q..."],
  "eth": ["0x..."],
  "sol": ["..."]
}
```

---

## 2. Setting Up Watchlists

Once you have the addresses, you should add them to "Address Watchlists" on major block explorers. Most services offer free accounts that allow for email or webhook notifications.

### Ethereum & EVM (Etherscan)
1.  Create an account on [Etherscan.io](https://etherscan.io/).
2.  Go to **My Profile** -> **Watch List**.
3.  Add each generated Ethereum address.
4.  Enable **Notify on Incoming & Outgoing Txns**.

### Solana (Solscan / Solana Explorer)
1.  Use services like [Solscan](https://solscan.io/) or the official Solana Explorer.
2.  Many Solana explorers support browser notifications or specialized tracking bots.

### Bitcoin (Blockchain.com / Mempool.space)
1.  Add addresses to a watch-only wallet in Bitcoin Core or use a web-based explorer that supports watchlists.

---

## 3. Integrating with Wazuh

To bring these on-chain alerts back into your Wazuh SIEM, you can use one of the following methods:

### Method A: Chain Monitor Script (Recommended)
Run a small script that periodically polls block explorer APIs for activity on your monitored addresses and logs the results to a file monitored by the Wazuh agent.

The Wazuh ruleset already includes a decoder for this format (Rule IDs 100530-100533):
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x...", "activity_type": "balance_query"}
```

### Method B: Email to Log
If your block explorer only supports email notifications, you can configure your mail server to pipe these emails into a script that writes to a local log file for Wazuh to ingest.

---

## Important Security Note
**NEVER deposit real funds into honeypot addresses.** The purpose of these addresses is to be "bait." If you deposit funds, an attacker who steals the key will be able to take those funds. The system is designed to detect the *attempted* use of the keys, not to trap real assets.
