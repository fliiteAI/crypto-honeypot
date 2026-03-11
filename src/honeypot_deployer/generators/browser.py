"""Browser extension decoy data generation.

Creates fake browser wallet extension data (MetaMask, Phantom, Exodus, Electrum)
at the correct local storage paths to trigger infostealers that target browser
extension wallet data.
"""

import json
import os
import time
from dataclasses import dataclass
from pathlib import Path


@dataclass
class BrowserDecoyConfig:
    """Configuration for a browser extension decoy."""

    extension_name: str
    extension_id: str
    browser: str
    vault_data: dict


# Known wallet extension IDs
EXTENSION_IDS = {
    "metamask_chrome": "nkbihfbeogaeaoehlefnkodbefgpgknn",
    "phantom_chrome": "bfnaelmomeimhlpmgjnjophhpkkoljpa",
    "coinbase_chrome": "hnfanknocfeofbddgcijnmhnfnkdnaad",
}


def _generate_metamask_vault(eth_address: str) -> dict:
    """Generate a realistic-looking MetaMask vault structure.

    The vault data is encrypted gibberish --- it looks right to automated scanners
    but contains no real secrets beyond the honeypot keys we already control.
    """
    # MetaMask stores encrypted vault in local storage
    fake_cipher = os.urandom(128).hex()
    fake_iv = os.urandom(16).hex()
    fake_salt = os.urandom(32).hex()

    return {
        "data": {
            "KeyringController": {
                "vault": json.dumps({
                    "data": fake_cipher,
                    "iv": fake_iv,
                    "salt": fake_salt,
                }),
            },
            "PreferencesController": {
                "selectedAddress": eth_address.lower(),
                "identities": {
                    eth_address.lower(): {
                        "address": eth_address.lower(),
                        "name": "Account 1",
                        "lastSelected": int(time.time() * 1000),
                    },
                },
            },
            "NetworkController": {
                "providerConfig": {
                    "type": "mainnet",
                    "chainId": "0x1",
                    "nickname": "Ethereum Mainnet",
                },
            },
            "AccountTracker": {
                "accounts": {
                    eth_address.lower(): {
                        "balance": "0x2386f26fc10000",  # ~0.01 ETH
                    },
                },
            },
            "CachedBalancesController": {
                "cachedBalances": {
                    "0x1": {
                        eth_address.lower(): "0x2386f26fc10000",
                    },
                },
            },
        },
        "meta": {
            "version": 74,
        },
    }


def _generate_phantom_vault(sol_address: str) -> dict:
    """Generate a realistic-looking Phantom wallet vault structure."""
    fake_cipher = os.urandom(128).hex()
    fake_iv = os.urandom(12).hex()

    return {
        "encryptedData": {
            "cipher": fake_cipher,
            "iv": fake_iv,
            "keyDerivation": "pbkdf2",
            "iterations": 600000,
        },
        "accounts": [
            {
                "publicKey": sol_address,
                "name": "Wallet 1",
                "type": "ed25519",
                "isImported": False,
            },
        ],
        "selectedAccount": sol_address,
        "network": "mainnet-beta",
        "version": 3,
    }


def _generate_exodus_data(addresses: dict[str, str]) -> dict:
    """Generate a realistic-looking Exodus wallet data structure."""
    fake_seed_cipher = os.urandom(256).hex()

    return {
        "meta": {
            "version": "24.1.15",
            "created": "2025-06-15T10:30:00.000Z",
            "modified": time.strftime("%Y-%m-%dT%H:%M:%S.000Z", time.gmtime()),
        },
        "seed": {
            "encrypted": fake_seed_cipher,
            "algorithm": "aes-256-gcm",
            "keyDerivation": "argon2id",
        },
        "wallets": {
            "bitcoin": {
                "address": addresses.get("btc", "bc1q" + os.urandom(20).hex()),
                "enabled": True,
            },
            "ethereum": {
                "address": addresses.get("eth", "0x" + os.urandom(20).hex()),
                "enabled": True,
            },
            "solana": {
                "address": addresses.get("sol", os.urandom(32).hex()),
                "enabled": True,
            },
        },
    }


def create_metamask_decoy(
    eth_address: str, output_path: Path
) -> Path:
    """Create a fake MetaMask Chrome extension local storage directory."""
    ext_id = EXTENSION_IDS["metamask_chrome"]
    ext_dir = output_path / "metamask" / ext_id

    ext_dir.mkdir(parents=True, exist_ok=True)

    vault = _generate_metamask_vault(eth_address)

    # MetaMask stores data in LevelDB format; we create a simplified JSON version
    # that triggers path-based scanners
    data_file = ext_dir / "000003.log"
    with open(data_file, "wb") as f:
        # Write a LevelDB-like header followed by JSON data
        f.write(b"\x00" * 8)  # LevelDB log header
        f.write(json.dumps(vault).encode("utf-8"))
        f.write(os.urandom(256))  # Padding

    # Also create the MANIFEST and CURRENT files that LevelDB expects
    manifest_file = ext_dir / "MANIFEST-000001"
    with open(manifest_file, "wb") as f:
        f.write(b"\x00" * 48)
        f.write(b"leveldb.BytewiseComparator")
        f.write(b"\x00" * 64)

    current_file = ext_dir / "CURRENT"
    with open(current_file, "w") as f:
        f.write("MANIFEST-000001\n")

    return ext_dir


def create_phantom_decoy(
    sol_address: str, output_path: Path
) -> Path:
    """Create a fake Phantom Chrome extension local storage directory."""
    ext_id = EXTENSION_IDS["phantom_chrome"]
    ext_dir = output_path / "phantom" / ext_id

    ext_dir.mkdir(parents=True, exist_ok=True)

    vault = _generate_phantom_vault(sol_address)

    data_file = ext_dir / "000003.log"
    with open(data_file, "wb") as f:
        f.write(b"\x00" * 8)
        f.write(json.dumps(vault).encode("utf-8"))
        f.write(os.urandom(256))

    current_file = ext_dir / "CURRENT"
    with open(current_file, "w") as f:
        f.write("MANIFEST-000001\n")

    return ext_dir


def create_exodus_decoy(
    addresses: dict[str, str], output_path: Path
) -> Path:
    """Create a fake Exodus desktop wallet data directory."""
    exodus_dir = output_path / "exodus" / "exodus.wallet"
    exodus_dir.mkdir(parents=True, exist_ok=True)

    data = _generate_exodus_data(addresses)

    wallet_file = exodus_dir / "seed.seco"
    with open(wallet_file, "wb") as f:
        # Exodus uses a custom encrypted format; create a binary blob
        # with recognizable header
        f.write(b"SECO\x00\x01")  # Exodus seco header
        f.write(os.urandom(16))  # IV
        f.write(json.dumps(data).encode("utf-8"))
        f.write(os.urandom(128))

    # Additional Exodus files
    info_file = exodus_dir / "info.seco"
    with open(info_file, "wb") as f:
        f.write(b"SECO\x00\x01")
        f.write(os.urandom(64))

    return exodus_dir


def create_electrum_decoy(
    btc_address: str, output_path: Path
) -> Path:
    """Create a fake Electrum wallet file."""
    electrum_dir = output_path / "electrum" / "wallets"
    electrum_dir.mkdir(parents=True, exist_ok=True)

    fake_keystore_cipher = os.urandom(128).hex()
    wallet_data = {
        "wallet_type": "standard",
        "keystore": {
            "type": "bip32",
            "xpub": "xpub6CUGRUo" + os.urandom(54).hex(),
            "pw_hash_version": 1,
            "encrypted": fake_keystore_cipher,
        },
        "addresses": {
            "receiving": [btc_address],
            "change": ["bc1q" + os.urandom(20).hex()],
        },
        "seed_version": 18,
        "use_encryption": True,
    }

    wallet_file = electrum_dir / "default_wallet"
    with open(wallet_file, "w") as f:
        json.dump(wallet_data, f, indent=2)

    return electrum_dir


def get_default_paths() -> dict[str, dict[str, str]]:
    """Return default browser extension decoy placement paths."""
    mm_id = EXTENSION_IDS["metamask_chrome"]
    ph_id = EXTENSION_IDS["phantom_chrome"]

    chrome_ext_linux = "~/.config/google-chrome/Default/Local Extension Settings"
    chrome_ext_win = (
        "%LOCALAPPDATA%\\Google\\Chrome\\User Data"
        "\\Default\\Local Extension Settings"
    )
    chrome_ext_mac = (
        "~/Library/Application Support/Google/Chrome"
        "/Default/Local Extension Settings"
    )

    return {
        "linux": {
            "metamask_chrome": f"{chrome_ext_linux}/{mm_id}/",
            "phantom_chrome": f"{chrome_ext_linux}/{ph_id}/",
            "exodus": "~/.config/Exodus/exodus.wallet/",
            "electrum": "~/.electrum/wallets/",
        },
        "windows": {
            "metamask_chrome": f"{chrome_ext_win}\\{mm_id}\\",
            "phantom_chrome": f"{chrome_ext_win}\\{ph_id}\\",
            "exodus": "%APPDATA%\\Exodus\\exodus.wallet\\",
            "electrum": "%APPDATA%\\Electrum\\wallets\\",
        },
        "macos": {
            "metamask_chrome": f"{chrome_ext_mac}/{mm_id}/",
            "phantom_chrome": f"{chrome_ext_mac}/{ph_id}/",
            "exodus": "~/Library/Application Support/Exodus/exodus.wallet/",
            "electrum": "~/.electrum/wallets/",
        },
    }


def generate_artifact_bundle(
    output_dir: Path,
    eth_address: str = "",
    sol_address: str = "",
    btc_address: str = "",
) -> dict:
    """Generate a complete browser extension decoy artifact bundle."""
    browser_dir = output_dir / "browser"
    artifact_files = {}

    addresses = {
        "btc": btc_address,
        "eth": eth_address,
        "sol": sol_address,
    }

    if eth_address:
        mm_dir = create_metamask_decoy(eth_address, browser_dir)
        artifact_files["metamask"] = str(mm_dir)

    if sol_address:
        ph_dir = create_phantom_decoy(sol_address, browser_dir)
        artifact_files["phantom"] = str(ph_dir)

    if any(addresses.values()):
        exodus_dir = create_exodus_decoy(addresses, browser_dir)
        artifact_files["exodus"] = str(exodus_dir)

    if btc_address:
        electrum_dir = create_electrum_decoy(btc_address, browser_dir)
        artifact_files["electrum"] = str(electrum_dir)

    return {
        "type": "browser_decoys",
        "artifact_files": artifact_files,
        "default_paths": get_default_paths(),
    }
