# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final and most definitive stage of detection in the Crypto Wallet Honeypot system. It allows you to detect when an attacker has successfully stolen a private key and is attempting to use it on the blockchain.

## Why Monitor On-Chain?

1. **Confirmation of Theft:** Local alerts (FIM) tell you a file was accessed. On-chain alerts tell you the attacker has successfully parsed the file and is actively evaluating the "loot."
2. **Persistence:** Even if an attacker wipes the logs on the compromised host, the record of their on-chain activity is permanent and publicly visible.
3. **Attacker Intelligence:** Monitoring where the attacker sends funds (even if they are just testing) can provide valuable intelligence on their infrastructure and destination wallets.

## Setting Up Monitoring

### 1. Export Honeypot Addresses
After generating your artifacts, use the CLI to export the public addresses into a convenient format:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

### 2. Choose a Monitoring Method

#### Option A: Block Explorer Watchlists (Easiest)
Most major block explorers allow you to create an account and set up "Watchlists" that send email or webhook notifications when an address sees activity.

- **Ethereum (ETH):** [Etherscan.io](https://etherscan.io/) -> My Account -> Watch List
- **Bitcoin (BTC):** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana (SOL):** [Solscan.io](https://solscan.io/)

#### Option B: Self-Hosted Monitoring Scripts
For a more private and automated solution, you can use Python scripts with Web3 libraries to poll the status of your addresses.

**Example (Ethereum/EVM):**
```python
from web3 import Web3
import json

w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_PROJECT_ID'))

with open('watch-list.json') as f:
    addresses = json.load(f)['eth']

for addr in addresses:
    balance = w3.eth.get_balance(addr)
    if balance > 0:
        print(f"CRITICAL: Activity on honeypot address {addr}!")
```

### 3. Integrate with Wazuh
If you use a custom script for monitoring, you can feed those events back into Wazuh for centralized alerting.

1. Configure your script to log events in JSON format to a file (e.g., `/var/log/honeypot-chain.log`).
2. Add a `localfile` entry to the Wazuh Manager or a dedicated monitoring agent:
```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/log/honeypot-chain.log</location>
</localfile>
```
3. Use the built-in honeypot rules (IDs 100530-100533) to trigger alerts.

## What to Watch For

- **Balance Queries:** Some "stealers" automatically query balances via common APIs (Infura, Alchemy, etc.) as soon as they ingest a key.
- **Incoming Transfers:** An attacker might send a small amount of "gas" (e.g., 0.005 ETH) to a stolen address to facilitate moving out other assets. **Any incoming transfer is a critical alert.**
- **Token Approvals:** In the world of DeFi, attackers often use stolen keys to sign `approve` transactions for malicious drainer contracts.

## Important Security Note

**Never deposit real funds into these honeypot addresses.** The private keys are stored in your deployment manifest and on the target endpoints. They are meant to be stolen. Any funds deposited will likely be lost immediately.
