# On-Chain Monitoring Guide

On-chain monitoring is the final and most critical layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect if an attacker has successfully exfiltrated a private key and is attempting to use it on the blockchain.

## Overview

Even if an attacker manages to bypass host-based detections or exfiltrate data via an offline method, they must eventually interact with the blockchain to check the balance of or move funds from the stolen wallet. By monitoring the public addresses of your honeypots, you can receive alerts the moment an attacker "touches" the bait.

## 1. Exporting Honeypot Addresses

The `honeypot-deployer` CLI allows you to export all public addresses generated during a deployment into a simple JSON format.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

The resulting file will look like this:

```json
{
  "btc": ["1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"],
  "eth": ["0x1234567890abcdef1234567890abcdef12345678"],
  "sol": ["Gv97SByvE5XvWjL2y7Lp15T9f4pZ4pZ4pZ4pZ4pZ4pZ"]
}
```

## 2. Setting Up Watchlists

Once you have the addresses, you should import them into various "Watchlist" services provided by block explorers and blockchain infrastructure providers.

### Ethereum & EVM (Etherscan / Polygonscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Profile** > **Watch List**.
3. Add your honeypot addresses.
4. Enable **Notify on Incoming & Outbound Txns**.

### Bitcoin (Blockchain.com / BlockCypher)
1. Use a service like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) that supports address subscriptions.
2. Many explorers allow you to set up email alerts for specific addresses.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/) and create an account.
2. Add your Solana honeypot addresses to your watchlist.

## 3. Automated Monitoring (Advanced)

For enterprise deployments, you can use a script or a service to monitor these addresses and feed events back into Wazuh.

### Integration with Wazuh
You can use a simple Python script that polls block explorer APIs for your honeypot addresses. If activity is detected, the script can log a JSON event to a file monitored by the Wazuh agent:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x123...",
  "activity_type": "outbound_transfer",
  "txid": "0xabc..."
}
```

Wazuh Rule **100530** is specifically designed to trigger a Level 15 alert when it sees this log format.

## 4. Why Monitor On-Chain?

1. **Confirmation of Theft:** Host-based alerts tell you someone *accessed* the file. On-chain alerts tell you they *stole* it and are using it.
2. **Attacker Attribution:** On-chain activity can sometimes be linked to exchange accounts or other known attacker infrastructure.
3. **Detection Persistence:** Even if the attacker wipes the compromised machine, the on-chain alert will still fire the moment they use the keys.
