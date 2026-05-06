# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect if an attacker has successfully exfiltrated a private key and imported it into their own wallet.

## How it Works

When you generate honeypot artifacts, the `honeypot-deployer` creates real (but empty) cryptocurrency addresses. By adding these addresses to "Watchlists" on public block explorers, you can receive email or webhook notifications the moment an attacker interacts with them on the blockchain.

## Step 1: Export Honeypot Addresses

First, use the CLI to export a clean list of all public addresses generated in your deployment.

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./watch-addresses.json
```

The output file will contain a list of addresses grouped by chain (BTC, ETH, SOL, etc.).

## Step 2: Set Up Watchlists

Register for an account on the following services to set up notifications for your honeypot addresses.

### Ethereum (and EVM Chains)
- **Service:** [Etherscan](https://etherscan.io/)
- **Feature:** "Watch List"
- **Instructions:**
    1. Log in to Etherscan.
    2. Go to `My Account` -> `Watch List`.
    3. Click `Add`.
    4. Enter the honeypot ETH address.
    5. Set notification to "Notify on Incoming & Outgoing Txns".

### Bitcoin
- **Service:** [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/)
- **Instructions:** Most explorers offer email alerts for specific BTC addresses.

### Solana
- **Service:** [Solscan](https://solscan.io/)
- **Instructions:** Use the "Account Tracking" feature to monitor your `id.json` addresses.

## Step 3: Integrate with Wazuh (Advanced)

For a fully integrated security operations center (SOC) experience, you can use the `honeypot-deployer` to check for on-chain activity and forward those results to Wazuh.

### Automated Chain Check
You can run a periodic script that checks the balance/activity of your honeypot addresses using the CLI:

```bash
# This feature is planned for a future release
# honeypot-deployer check-on-chain --manifest ./manifest.json
```

## Security Best Practices

1. **NEVER Deposit Funds:** These addresses are honeypots. Any funds deposited will likely be stolen if an attacker has compromised your system.
2. **Watch for "Balance Queries":** Some attackers will simply check the balance of a stolen key without making a transaction. On-chain monitoring might not detect this unless they perform an on-chain action.
3. **Attribution:** If an attacker moves funds *from* a honeypot address to an exchange, you can provide that information to law enforcement for potential attribution.
