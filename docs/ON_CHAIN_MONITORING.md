# On-Chain Monitoring Guide

The 4th layer of detection in the Crypto Wallet Honeypot system is on-chain monitoring. Even if an attacker successfully exfiltrates the keys without triggering a local alert, they will eventually need to use those keys on-chain.

## How it Works

1. **Generation:** When you run `honeypot-deployer generate`, the system creates unique private/public key pairs.
2. **Export:** You export these public addresses using the CLI.
3. **Watchlist:** You add these addresses to a watchlist on various block explorers or monitoring services.
4. **Alert:** When the attacker imports the seed phrase or private key into a wallet and performs a transaction (even just a balance check that touches a public RPC), the monitor triggers.

## Exporting Addresses

Use the `export-addresses` command to get a list of all public addresses in your deployment:

```bash
honeypot-deployer export-addresses \
  --manifest ./manifest.json \
  --output ./watchlist.json
```

## Setting Up Watchlists

### Ethereum / EVM (Etherscan)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Go to **My Profile** > **Watch List**.
3. Add the exported Ethereum addresses.
4. Enable "Email Notification" for both "Incoming & Outgoing" transactions.

### Bitcoin (Blockchain.com / Blockstream)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or set up a local `bitcoind` with `importaddress` (watch-only).
2. For SMBs, third-party "Address Trackers" are often the simplest solution.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use the "Account Tracking" feature or create an account to manage a watchlist of your honeypot `id.json` addresses.

## Automated Monitoring (Advanced)

For organizations with multiple deployments, you can use the `watchlist.json` with custom scripts or webhooks from services like:
- **Alchemy Notify:** Get webhooks for address activity.
- **Tenderly:** Set up real-time alerts for EVM chains.
- **QuickNode Functions:** Trigger automated responses when a honeypot address is active.

## Integrating with Wazuh

If you receive an on-chain alert, you can manually correlate it with your Wazuh logs using the Rule ID `100530`.

**Note:** Since the honeypot addresses contain no real funds, any **outgoing** transaction is a 100% confirmed compromise of the private key.
