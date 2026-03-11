#!/bin/bash

# Define honeyfile paths
BITCOIN_DIR="$HOME/.bitcoin"
BITCOIN_WALLET="$BITCOIN_DIR/wallet.dat"

ETHEREUM_DIR="$HOME/.ethereum/keystore"
ETHEREUM_WALLET="$ETHEREUM_DIR/UTC--2023-10-27T10-00-00.000Z--1234567890abcdef1234567890abcdef12345678"

SOLANA_DIR="$HOME/.config/solana"
SOLANA_WALLET="$SOLANA_DIR/id.json"

ELECTRUM_DIR="$HOME/.electrum/wallets"
ELECTRUM_WALLET="$ELECTRUM_DIR/default_wallet"

EXODUS_DIR="$HOME/.config/Exodus/exodus.wallet"
EXODUS_DUMMY="$EXODUS_DIR/seed.secur"

# Browser Extension IDs
METAMASK_ID="nkbihfbeogaeaoehlefnkodbefgpgknn"
PHANTOM_ID="bfnaelmomeimhlpmgjnjophhpkkoljpa"
TRONLINK_ID="ibnejdfjmmkpcnlpebklmnkoeoihofec"
COINBASE_ID="hnfanknocfeofbddgcijnmhnfnkdnaad"
BINANCE_ID="cadiboklkpojfamcoggejbbdjcoiljjk"

# Chrome-based browser paths (Linux)
CHROME_SETTINGS="$HOME/.config/google-chrome/Default/Local Extension Settings"
BRAVE_SETTINGS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings"

# Create core directories
mkdir -p "$BITCOIN_DIR"
mkdir -p "$ETHEREUM_DIR"
mkdir -p "$SOLANA_DIR"
mkdir -p "$ELECTRUM_DIR"
mkdir -p "$EXODUS_DIR"

chmod 700 "$BITCOIN_DIR"
chmod 700 "$HOME/.ethereum" 2>/dev/null
chmod 700 "$ETHEREUM_DIR"
chmod 700 "$SOLANA_DIR"
chmod 700 "$HOME/.electrum" 2>/dev/null
chmod 700 "$ELECTRUM_DIR"
chmod 700 "$HOME/.config/Exodus" 2>/dev/null
chmod 700 "$EXODUS_DIR"

# Create Extension Honeyfolders
for browser in "$CHROME_SETTINGS" "$BRAVE_SETTINGS"; do
    for ext_id in "$METAMASK_ID" "$PHANTOM_ID" "$TRONLINK_ID" "$COINBASE_ID" "$BINANCE_ID"; do
        ext_path="$browser/$ext_id"
        mkdir -p "$ext_path"
        chmod 700 "$ext_path"
        # Create dummy LevelDB-like files targeted by stealers
        echo "{\"vault\":\"{\\\"data\\\":\\\"fakevaultdata\\\",\\\"iv\\\":\\\"fakeiv\\\",\\\"salt\\\":\\\"fakesalt\\\"}\"}" > "$ext_path/000003.log"
        echo "MANIFEST-000001" > "$ext_path/MANIFEST-000001"
        echo "leveldb.BytewiseComparator" > "$ext_path/CURRENT"
        touch "$ext_path/000005.ldb"

        chmod 600 "$ext_path/000003.log"
        chmod 600 "$ext_path/MANIFEST-000001"
        chmod 600 "$ext_path/CURRENT"
        chmod 600 "$ext_path/000005.ldb"
    done
done

# Create Bitcoin honeyfile (Binary-like)
echo -ne "\x00\x05\x31\x62\x74\x63\x00\x00\x00\x00\x01\x00\x00\x00\xde\xad\xbe\xef\xca\xfe\xba\xbe" > "$BITCOIN_WALLET"

# Create Ethereum honeyfile (JSON)
cat <<EOF > "$ETHEREUM_WALLET"
{
  "address": "1234567890abcdef1234567890abcdef12345678",
  "crypto": {
    "cipher": "aes-128-ctr",
    "ciphertext": "60357788f28246d888e4042217c3761899147e4d84f2278912e96020739c362b",
    "cipherparams": {
      "iv": "320e8954784a9611f81d184427e02927"
    },
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 262144,
      "p": 1,
      "r": 8,
      "salt": "a4d872f9b2c39a8c1f32a5e4d2b10a9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f32"
    },
    "mac": "2816934c9c64a5c6d3624e52002302633075c3f374343e06103606f3e792c906"
  },
  "id": "a9876543-210b-4321-8765-43210abcdef9",
  "version": 3
}
EOF

# Create Solana honeyfile (Byte array)
echo "[$(shuf -i 0-255 -n 64 | paste -sd "," -)]" > "$SOLANA_WALLET"

# Create Electrum honeyfile (JSON/Text)
cat <<EOF > "$ELECTRUM_WALLET"
{
    "addresses": {
        "receiving": [
            "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        ]
    },
    "keystore": {
        "type": "bip32",
        "xpub": "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGfQ2xyV7iZR2AgUSDH2CTSEPDD3p5P2uFn2q2Hn6P97WpAUpD3Mv5e2j9",
        "xprv": "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wS8jX6m9n1G3x8d9n2k5b4g3f2e1d0c9b8a7f6e5d4c3b2a1a0z9y8x7w6v5u4t3s2r1"
    },
    "wallet_type": "standard"
}
EOF

# Create Exodus dummy
echo "DUMMY_SEED_DATA_FOR_HONEYPOT" > "$EXODUS_DUMMY"

# Set file permissions
chmod 600 "$BITCOIN_WALLET"
chmod 600 "$ETHEREUM_WALLET"
chmod 600 "$SOLANA_WALLET"
chmod 600 "$ELECTRUM_WALLET"
chmod 600 "$EXODUS_DUMMY"

echo "Linux Honeypot deployment complete."
