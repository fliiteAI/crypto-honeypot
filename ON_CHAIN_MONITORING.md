# On-Chain Monitoring Guide: Tracking Honeypot Assets

This guide explains how to establish and track real bait addresses on supported blockchains to detect when an attacker imports stolen keys and attempts to move funds or interact with the chain.

## Overview
While the primary detection layer is the local filesystem (Wazuh FIM/Audit), on-chain monitoring provides a final, high-fidelity layer of detection. If an attacker imports a honeypot private key, they will likely query its balance or attempt a transfer.

## Supported Chains

### Bitcoin (BTC)
- **Monitoring:** Use a public block explorer or your own node to watch for any activity on the generated addresses.
- **Explorers:** [mempool.space](https://mempool.space/), [Blockchain.com](https://www.blockchain.com/explorer).
- **Setup:** The `honeypot-deployer` generates legacy (P2PKH), SegWit (P2SH), and Native SegWit (Bech32) addresses for maximum coverage.

### Ethereum (ETH/EVM)
- **Monitoring:** Watch for any transactions, token approvals, or balance changes.
- **Explorers:** [Etherscan](https://etherscan.io/), [Polygonscan](https://polygonscan.com/).
- **Setup:** Monitor the address on multiple EVM-compatible networks (Mainnet, Polygon, BSC, etc.) as attackers often bridge or check balances across multiple chains.

### Solana (SOL)
- **Monitoring:** Monitor for SOL transfers or SPL token account creation.
- **Explorers:** [Solscan](https://solscan.io/), [Solana Explorer](https://explorer.solana.com/).

### XRP Ledger (XRP)
- **Monitoring:** Watch for account activation or payment transactions.
- **Explorers:** [XRPScan](https://xrpscan.com/).

### Cardano (ADA)
- **Monitoring:** Monitor for UTXO changes or stake registration.
- **Explorers:** [Cardanoscan](https://cardanoscan.io/).

---

## Establishing Bait Addresses

1. **Generate Manifest:** Run the generator to create your unique honeypot keys.
   ```bash
   honeypot-deployer generate --output ./my-artifacts
   ```
2. **Export Addresses:** Export the list of addresses to a JSON file for monitoring.
   ```bash
   honeypot-deployer export-addresses --manifest ./my-artifacts/manifest.json --output ./monitored-addresses.json
   ```
3. **Funding (Optional but Recommended):** While not required for detection, adding a tiny amount of "dust" (e.g., $1 worth of assets) can increase the bait's effectiveness by encouraging attackers to attempt a withdrawal.
   - **Warning:** Never use significant funds. Any funds placed on these addresses should be considered "lost" if an alert is triggered.

---

## Tracking Strategy

### 1. Block Explorer Alerts
Most major block explorers (Etherscan, Solscan, etc.) allow you to create free accounts and set up "Watch Lists" that send email notifications when activity occurs on a specific address.

### 2. Custom Chain Monitor Service
For enterprise-scale deployments, we recommend using a dedicated monitoring script that polls public APIs or listens to websocket events.

Example polling logic:
```python
# Pseudo-code for a simple monitor
for chain, addresses in monitored_addresses.items():
    for addr in addresses:
        balance = get_balance(chain, addr)
        if balance > 0 or has_recent_transactions(chain, addr):
            trigger_wazuh_alert(chain, addr)
```

### 3. Wazuh Integration
The `honeypot-deployer` includes Wazuh rules (IDs 100530-100533) designed to ingest logs from a chain monitoring service. Your monitor should output JSON logs to a file monitored by the Wazuh agent:

```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x...", "activity_type": "outbound_transfer"}
```

---

## Security Considerations
- **Private Key Storage:** Ensure the `manifest.json` is encrypted and stored securely. If the manifest is compromised, the honeypot addresses must be rotated.
- **Privacy:** Avoid using your own personal or business accounts to fund bait addresses to prevent linking your identity to the honeypot infrastructure.
