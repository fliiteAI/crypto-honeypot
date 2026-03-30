# On-Chain Monitoring Guide: Crypto Wallet Honeypot

Monitoring the public addresses of your honeypot wallets on the blockchain provides a powerful, final layer of detection. If an attacker imports a stolen private key into their own wallet, they may perform on-chain actions that can be detected without any endpoint-level logs.

## 1. Exporting Honeypot Addresses

After generating your honeypot artifacts, use the `export-addresses` command to get a list of all public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

This will produce a JSON file containing the addresses organized by chain:

```json
{
  "btc": ["1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"],
  "eth": ["0x1234567890abcdef1234567890abcdef12345678"],
  "sol": ["AbCdEfGhIjKlMnOpQrStUvWxYz0123456789ABCDE"]
}
```

## 2. Using Block Explorer Watchlists (Recommended)

The easiest way to monitor these addresses is by using the "Watchlist" or "Address Alert" features of popular block explorers. Most services allow you to receive email or webhook notifications for any activity on a specific address.

### Ethereum (and EVM Chains)
-   **Service:** [Etherscan](https://etherscan.io/)
-   **Setup:** Create an account, go to the "Watch List" section, and add your honeypot ETH addresses. Enable email notifications for all incoming and outgoing transactions.

### Bitcoin
-   **Service:** [Blockchain.com](https://www.blockchain.com/explorer) or [Blockstream.info](https://blockstream.info/)
-   **Setup:** Many Bitcoin explorers offer similar alerting services. Alternatively, you can use a hardware wallet or software wallet in "watch-only" mode.

### Solana
-   **Service:** [Solscan](https://solscan.io/)
-   **Setup:** Similar to Etherscan, Solscan allows you to track addresses and set up alerts for activity.

## 3. Automated Monitoring with Chain Monitor

If you want to integrate on-chain alerts directly into Wazuh, you can use a custom script or service (the "Chain Monitor") that polls these addresses via RPC or a block explorer API.

### Integrating with Wazuh
1.  **Script:** A Python or Node.js script that periodically checks the balance and transaction history of the exported addresses.
2.  **Log Output:** When activity is detected, the script should output a JSON log message.
3.  **Wazuh Log Collection:** Configure the Wazuh agent to monitor the log file produced by your script.
4.  **Wazuh Rules:** The system already includes rules (100530-100533) designed to parse these logs and trigger high-severity alerts.

## 4. Why Monitor On-Chain?

-   **Confirmation of Theft:** Endpoint logs only show that a file was *accessed*. On-chain activity confirms that the attacker has successfully *stolen and used* the keys.
-   **Detection Beyond the Perimeter:** If an attacker exfiltrates the keys and uses them from an entirely different machine, endpoint logs will not help. On-chain monitoring is the only way to detect this.
-   **Zero False Positives:** Since these addresses should *never* have any legitimate activity, any transaction or balance query is a guaranteed indicator of an attack.
