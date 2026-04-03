# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot's detection strategy. By watching the public addresses of your honeypots on their respective blockchains, you can definitively confirm if an attacker has successfully exfiltrated and attempted to use the stolen keys.

## How it Works

1.  **Generate Addresses:** Use the `honeypot-deployer generate` command to create your honeypots.
2.  **Export Addresses:** Run `honeypot-deployer export-addresses` to create a JSON file containing all public addresses.
3.  **Add to Watchlists:** Import these addresses into a block explorer's "Watchlist" or "Address Alert" service.
4.  **Receive Alerts:** The block explorer will send you an email or webhook notification whenever a transaction or balance query occurs.

## Setting Up Watchlists

### Ethereum & EVM Chains (Etherscan, Polygonscan, etc.)
- Create an account on [Etherscan](https://etherscan.io/).
- Go to **Account** -> **Watch List**.
- Click **Add** and paste your exported Ethereum addresses.
- Select "Notify on Outgoing & Incoming Txns".

### Bitcoin (Blockchain.com, Mempool.space)
- Use [Mempool.space](https://mempool.space/) to monitor addresses without an account for individual checks.
- For automated alerts, services like [Blockonomics](https://www.blockonomics.co/) or [Blockchain.com](https://www.blockchain.com/) wallets offer address monitoring.

### Solana (Solscan)
- Create an account on [Solscan](https://solscan.io/).
- Use the **Account Alert** feature to monitor your Solana addresses.

## Automating with Wazuh

For advanced users, you can feed block explorer webhooks back into Wazuh for centralized alerting.

1.  Set up a simple listener script that accepts webhooks from your block explorer.
2.  Format the incoming data as JSON.
3.  Write the JSON to a log file (e.g., `/var/log/chain-monitor/events.json`).
4.  Configure the Wazuh Manager to monitor this file (see `wazuh/agent-config/ossec-log-collector.conf`).

The custom rules in `wazuh/rules/honeypot_rules.xml` (IDs 100530-100533) are already configured to process these events and trigger Level 15 alerts.

## Why Non-Funded?

We strongly recommend **never** placing real funds in your honeypots. The goal is to detect the *act* of access and the *attempt* to move funds. Attacker activity like balance queries (often done via automated scripts) is enough to trigger a high-fidelity alert.
