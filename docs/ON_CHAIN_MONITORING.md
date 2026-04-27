# On-Chain Monitoring Guide

On-chain monitoring is the fourth layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect if an attacker has successfully exfiltrated a private key and is attempting to use it on the blockchain.

## Overview

Even if an attacker manages to bypass local endpoint security and exfiltrate honeypot files, they still need to import the keys into a wallet to access the (non-existent) funds. By placing the public addresses of your honeypots on a "watchlist" using block explorers or custom scripts, you can receive alerts the moment any activity occurs on those addresses.

## Step 1: Export Honeypot Addresses

The `honeypot-deployer` CLI provides a convenient way to extract all public addresses from your deployment manifest.

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/your/manifest.json \
  --output ./honeypot-addresses.json
```

The output will be a JSON file containing the addresses organized by chain:

```json
{
  "btc": ["bc1q...", "bc1p..."],
  "eth": ["0x...", "0x..."],
  "sol": ["...", "..."]
}
```

## Step 2: Set Up Block Explorer Watchlists

The easiest way to monitor addresses is by using the built-in "Watchlist" or "Address Alert" features of popular block explorers.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Account** > **Watch List**.
3. Click **Add** and paste your honeypot Ethereum address.
4. Select "Notify on Incoming & Outgoing Txns".
5. Repeat for other EVM chains (BSC, Polygon, etc.) if applicable.

### Bitcoin (Blockchain.com, BlockCypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) that offer address subscription APIs or webhooks.
2. Alternatively, use a self-hosted Electrum server or a dedicated monitoring tool like `bitcoin-monitor`.

### Solana (Solscan, SolanaFM)
1. Use [Solscan](https://solscan.io/) and create an account.
2. Add your Solana addresses to the "Account Notification" list.

## Step 3: Advanced Monitoring (Optional)

For high-security environments, you may want to implement custom monitoring scripts that query the blockchain directly via RPC nodes.

### Example: Python Monitoring Script
You can use libraries like `web3.py` (Ethereum) or `solana-py` (Solana) to poll for balance changes.

```python
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_PROJECT_ID'))
address = "0x..." # Your honeypot address

def check_balance():
    balance = w3.eth.get_balance(address)
    if balance > 0:
        print(f"ALERT: Balance detected on honeypot address {address}!")

# Run this on a cron job or as a daemon
```

## Interpreting On-Chain Alerts

Since the honeypot addresses are **non-funded**, any activity is suspicious:

1. **Balance Check / Small Inbound Transfer:** The attacker may have sent a small amount of "gas" money to the address to enable a subsequent outbound transfer.
2. **Token Transfer:** The attacker is attempting to move assets they *think* are on the address.
3. **Contract Interaction:** The attacker is trying to use the address to interact with DeFi protocols.

**Action:** If an on-chain alert is triggered, correlate it immediately with your Wazuh FIM logs to identify the compromised endpoint and the time of exfiltration.
