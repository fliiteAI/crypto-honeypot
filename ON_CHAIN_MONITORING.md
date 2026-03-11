# On-Chain Monitoring for Crypto Honeypots

To maximize the effectiveness of your honeypot, you should use "real" on-chain wallet addresses. This allows you to monitor if an attacker has successfully exfiltrated the credentials and is attempting to move funds.

## 1. Creating Bait Addresses

### Bitcoin (BTC)
- **Method:** Use [Electrum](https://electrum.org/) or [Bitcoin Core](https://bitcoincore.org/).
- **Step:** Create a new wallet, generate a receiving address, and export the `wallet.dat` or the private key.
- **Honeypot Integration:** Replace the dummy `wallet.dat` in the honeypot with your real (but empty) bait wallet.

### Ethereum (ETH)
- **Method:** Use [MyEtherWallet (MEW)](https://www.myetherwallet.com/) or [Geth](https://geth.ethereum.org/).
- **Step:** Create a new wallet and download the **Keystore File (UTC/JSON)**.
- **Honeypot Integration:** Place this Keystore file in the `~/.ethereum/keystore/` directory of your honeypot.

### Solana (SOL)
- **Method:** Use the [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools).
- **Step:** Run `solana-keygen new --outfile bait-id.json`.
- **Honeypot Integration:** Use the contents of `bait-id.json` for your `~/.config/solana/id.json` decoy.

### Cardano (ADA)
- **Method:** Use [Yoroi](https://yoroi-wallet.com/) or [Daedalus](https://daedaluswallet.io/).
- **Step:** Create a new wallet and save the recovery phrase.
- **Honeypot Integration:** Create a `seed.txt` or `recovery.txt` file in a common directory (e.g., `~/Documents`) with the recovery phrase.

---

## 2. Monitoring Activity

Once your bait addresses are deployed, monitor them using public block explorers. You can set up "Watch-only" wallets or use automated alerting services.

### Block Explorers
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Ethereum:** [Etherscan.io](https://etherscan.io/)
- **Solana:** [Solscan.io](https://solscan.io/)
- **Cardano:** [Cardanoscan.io](https://cardanoscan.io/)

### Setting Up Alerts
Most major explorers allow you to create an account and add "Watchlist" addresses. They will send you an email or webhook notification whenever:
1. Funds are deposited (less likely for a honeypot).
2. **Funds are withdrawn or attempted to be moved (Critical Indicator of Compromise).**

### Security Note
**NEVER** put real funds into these bait addresses. Their purpose is to detect credential theft, not to act as a financial trap. If you see activity on these addresses, assume the host machine and the associated user account are fully compromised.
