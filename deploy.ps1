# Define base paths
$AppData = [System.Environment]::GetFolderPath('ApplicationData')
$LocalData = [System.Environment]::GetFolderPath('LocalApplicationData')

# Core Wallet Paths
$BITCOIN_DIR = "$AppData\Bitcoin"
$BITCOIN_WALLET = "$BITCOIN_DIR\wallet.dat"

$ETHEREUM_DIR = "$AppData\Ethereum\keystore"
$ETHEREUM_WALLET = "$ETHEREUM_DIR\UTC--2023-10-27T10-00-00.000Z--1234567890abcdef1234567890abcdef12345678"

$ELECTRUM_DIR = "$AppData\Electrum\wallets"
$ELECTRUM_WALLET = "$ELECTRUM_DIR\default_wallet"

$EXODUS_DIR = "$AppData\Exodus\exodus.wallet"
$EXODUS_DUMMY = "$EXODUS_DIR\seed.secur"

# Browser Extension IDs
$EXT_IDS = @(
    "nkbihfbeogaeaoehlefnkodbefgpgknn", # MetaMask
    "bfnaelmomeimhlpmgjnjophhpkkoljpa", # Phantom
    "ibnejdfjmmkpcnlpebklmnkoeoihofec", # TronLink
    "hnfanknocfeofbddgcijnmhnfnkdnaad", # Coinbase Wallet
    "cadiboklkpojfamcoggejbbdjcoiljjk"  # Binance Wallet
)

# Browser paths for extensions
$BROWSER_PATHS = @(
    "$LocalData\Google\Chrome\User Data\Default\Local Extension Settings",
    "$LocalData\Microsoft\Edge\User Data\Default\Local Extension Settings",
    "$LocalData\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings"
)

# Create core directories
New-Item -ItemType Directory -Force -Path $BITCOIN_DIR
New-Item -ItemType Directory -Force -Path $ETHEREUM_DIR
New-Item -ItemType Directory -Force -Path $ELECTRUM_DIR
New-Item -ItemType Directory -Force -Path $EXODUS_DIR

# Create Extension Honeyfolders
foreach ($browserPath in $BROWSER_PATHS) {
    foreach ($extId in $EXT_IDS) {
        $fullPath = Join-Path $browserPath $extId
        New-Item -ItemType Directory -Force -Path $fullPath
        Set-Content -Path (Join-Path $fullPath "000003.log") -Value "{\"vault\":\"{\\\"data\\\":\\\"fakevaultdata\\\",\\\"iv\\\":\\\"fakeiv\\\",\\\"salt\\\":\\\"fakesalt\\\"}\"}"
        Set-Content -Path (Join-Path $fullPath "MANIFEST-000001") -Value "MANIFEST-000001"
        Set-Content -Path (Join-Path $fullPath "CURRENT") -Value "leveldb.BytewiseComparator"
        New-Item -ItemType File -Force -Path (Join-Path $fullPath "000005.ldb")
    }
}

# Create Bitcoin honeyfile (Binary-like)
[byte[]]$btc_bytes = 0x00, 0x05, 0x31, 0x62, 0x74, 0x63, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe
[System.IO.File]::WriteAllBytes($BITCOIN_WALLET, $btc_bytes)

# Create Ethereum honeyfile (JSON)
$eth_content = @'
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
'@
Set-Content -Path $ETHEREUM_WALLET -Value $eth_content

# Create Electrum honeyfile (JSON/Text)
$electrum_content = @'
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
'@
Set-Content -Path $ELECTRUM_WALLET -Value $electrum_content

# Create Exodus dummy
Set-Content -Path $EXODUS_DUMMY -Value "DUMMY_SEED_DATA_FOR_HONEYPOT"

Write-Host "Windows Honeypot deployment complete."
