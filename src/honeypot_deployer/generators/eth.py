"""Ethereum/EVM honeypot wallet key generation and artifact creation."""

import json
import time
from dataclasses import dataclass
from pathlib import Path

from eth_account import Account


@dataclass
class ETHKeypair:
    """An Ethereum keypair for honeypot deployment."""

    private_key_hex: str
    address: str  # 0x-prefixed checksum address


def generate_eth_keypair() -> ETHKeypair:
    """Generate a new Ethereum keypair suitable for honeypot use."""
    account = Account.create()
    return ETHKeypair(
        private_key_hex=account.key.hex(),
        address=account.address,
    )


def create_keystore_artifact(
    keypair: ETHKeypair, output_path: Path, password: str = "password123"
) -> Path:
    """Create a realistic Ethereum keystore (UTC/JSON) file.

    Uses the standard Web3 keystore format with a deliberately weak password
    to make it tempting for attackers.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Use standard eth-account keystore encryption
    # Ensure private key is passed as bytes
    priv_key = keypair.private_key_hex
    if priv_key.startswith("0x"):
        priv_key = priv_key[2:]
    keystore = Account.encrypt(bytes.fromhex(priv_key), password)

    # Generate realistic filename matching geth convention
    timestamp = time.strftime("%Y-%m-%dT%H-%M-%S", time.gmtime())
    address_no_prefix = keypair.address.lower().replace("0x", "")
    filename = f"UTC--{timestamp}.000000000Z--{address_no_prefix}"

    keystore_file = output_path / filename
    with open(keystore_file, "w") as f:
        json.dump(keystore, f, indent=2)

    return keystore_file


def create_dotenv_artifact(keypair: ETHKeypair, output_path: Path) -> Path:
    """Create a .env file containing an Ethereum private key.

    Simulates a developer environment with an exposed private key --- a common
    target for attackers scanning for leaked credentials.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    env_file = output_path / ".env"
    env_content = f"""# Ethereum development configuration
# WARNING: Do not commit this file to version control!

ETHEREUM_NETWORK=mainnet
INFURA_API_KEY=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4
PRIVATE_KEY={keypair.private_key_hex}
WALLET_ADDRESS={keypair.address}
GAS_LIMIT=21000
GAS_PRICE_GWEI=20

# Contract addresses
TOKEN_CONTRACT=0xdAC17F958D2ee523a2206206994597C13D831ec7
ROUTER_CONTRACT=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
"""
    with open(env_file, "w") as f:
        f.write(env_content)

    return env_file


def get_default_paths() -> dict[str, str]:
    """Return default keystore placement paths per OS."""
    return {
        "linux": "~/.ethereum/keystore/",
        "windows": "%APPDATA%\\Ethereum\\keystore\\",
        "macos": "~/Library/Ethereum/keystore/",
        "dotenv_linux": "~/projects/defi-bot/.env",
        "dotenv_windows": "%USERPROFILE%\\projects\\defi-bot\\.env",
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete ETH honeypot artifact bundle.

    Returns a manifest dict with keypair info and artifact paths.
    """
    keypair = generate_eth_keypair()

    keystore_dir = output_dir / "eth" / "keystore"
    keystore_file = create_keystore_artifact(keypair, keystore_dir)

    dotenv_dir = output_dir / "eth" / "dotenv"
    dotenv_file = create_dotenv_artifact(keypair, dotenv_dir)

    return {
        "chain": "eth",
        "address": keypair.address,
        "private_key_hex": keypair.private_key_hex,
        "keystore_password": "password123",
        "artifact_files": {
            "keystore": str(keystore_file),
            "dotenv": str(dotenv_file),
        },
        "default_paths": get_default_paths(),
    }
