"""Solana honeypot wallet key generation and artifact creation."""

import json
from dataclasses import dataclass
from pathlib import Path

import base58
import nacl.signing


@dataclass
class SOLKeypair:
    """A Solana keypair for honeypot deployment."""

    private_key_bytes: bytes  # 64-byte ed25519 keypair (secret + public)
    public_key_bytes: bytes  # 32-byte public key
    address: str  # Base58-encoded public key


def generate_sol_keypair() -> SOLKeypair:
    """Generate a new Solana keypair suitable for honeypot use."""
    signing_key = nacl.signing.SigningKey.generate()
    verify_key = signing_key.verify_key

    # Solana keypair format: 64 bytes = 32-byte secret + 32-byte public
    private_key_bytes = bytes(signing_key) + bytes(verify_key)
    public_key_bytes = bytes(verify_key)
    address = base58.b58encode(public_key_bytes).decode("ascii")

    return SOLKeypair(
        private_key_bytes=private_key_bytes,
        public_key_bytes=public_key_bytes,
        address=address,
    )


def create_id_json_artifact(keypair: SOLKeypair, output_path: Path) -> Path:
    """Create a Solana CLI id.json keypair file.

    This is the standard format produced by `solana-keygen new` --- a JSON array
    of 64 byte values representing the full ed25519 keypair.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    id_file = output_path / "id.json"
    # Standard Solana CLI format: JSON array of byte values
    keypair_list = list(keypair.private_key_bytes)

    with open(id_file, "w") as f:
        json.dump(keypair_list, f)

    return id_file


def create_cli_config_artifact(keypair: SOLKeypair, output_path: Path) -> Path:
    """Create a realistic Solana CLI config.yml file.

    Points to mainnet-beta to make the honeypot look like an active wallet.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    config_file = output_path / "cli" / "config.yml"
    config_file.parent.mkdir(parents=True, exist_ok=True)

    config_content = """---
json_rpc_url: https://api.mainnet-beta.solana.com
websocket_url: ""
keypair_path: ~/.config/solana/id.json
address_labels:
  "11111111111111111111111111111111": System Program
commitment: confirmed
"""
    with open(config_file, "w") as f:
        f.write(config_content)

    return config_file


def get_default_paths() -> dict[str, str]:
    """Return default Solana wallet placement paths per OS."""
    return {
        "linux": "~/.config/solana/id.json",
        "windows": "%USERPROFILE%\\.config\\solana\\id.json",
        "macos": "~/.config/solana/id.json",
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete SOL honeypot artifact bundle.

    Returns a manifest dict with keypair info and artifact paths.
    """
    keypair = generate_sol_keypair()

    sol_dir = output_dir / "sol"
    id_file = create_id_json_artifact(keypair, sol_dir)
    config_file = create_cli_config_artifact(keypair, sol_dir)

    return {
        "chain": "sol",
        "address": keypair.address,
        "private_key_hex": keypair.private_key_bytes[:32].hex(),
        "artifact_files": {
            "id_json": str(id_file),
            "cli_config": str(config_file),
        },
        "default_paths": get_default_paths(),
    }
