"""Cardano (ADA) honeypot wallet key generation and artifact creation."""

import json
from dataclasses import dataclass
from pathlib import Path

import nacl.signing


@dataclass
class ADAKeypair:
    """A Cardano keypair for honeypot deployment."""

    private_key_hex: str  # 64-byte ed25519 extended signing key
    public_key_hex: str  # 32-byte ed25519 verification key
    address_hex: str  # Placeholder address identifier


def generate_ada_keypair() -> ADAKeypair:
    """Generate a new Cardano keypair suitable for honeypot use.

    Cardano uses Ed25519 extended keys. We generate a standard Ed25519 keypair
    which is structurally valid for triggering infostealer detection.
    """
    signing_key = nacl.signing.SigningKey.generate()
    verify_key = signing_key.verify_key

    private_key_hex = bytes(signing_key).hex()
    public_key_hex = bytes(verify_key).hex()

    # Simplified address identifier (Cardano addresses are complex Bech32;
    # for honeypot purposes, we use the public key hash as an identifier)
    import hashlib

    addr_hash = hashlib.blake2b(bytes(verify_key), digest_size=28).hexdigest()
    address_hex = addr_hash

    return ADAKeypair(
        private_key_hex=private_key_hex,
        public_key_hex=public_key_hex,
        address_hex=address_hex,
    )


def create_skey_artifact(keypair: ADAKeypair, output_path: Path) -> Path:
    """Create a Cardano signing key (.skey) file.

    Uses the standard TextEnvelope JSON format that cardano-cli produces.
    """
    output_path.mkdir(parents=True, exist_ok=True)

    skey_file = output_path / "payment.skey"
    skey_data = {
        "type": "PaymentSigningKeyShelley_ed25519",
        "description": "Payment Signing Key",
        "cborHex": "5820" + keypair.private_key_hex,
    }

    with open(skey_file, "w") as f:
        json.dump(skey_data, f, indent=4)

    return skey_file


def create_vkey_artifact(keypair: ADAKeypair, output_path: Path) -> Path:
    """Create a Cardano verification key (.vkey) file."""
    output_path.mkdir(parents=True, exist_ok=True)

    vkey_file = output_path / "payment.vkey"
    vkey_data = {
        "type": "PaymentVerificationKeyShelley_ed25519",
        "description": "Payment Verification Key",
        "cborHex": "5820" + keypair.public_key_hex,
    }

    with open(vkey_file, "w") as f:
        json.dump(vkey_data, f, indent=4)

    return vkey_file


def get_default_paths() -> dict[str, str]:
    """Return default Cardano wallet placement paths."""
    return {
        "linux": "~/.cardano/payment.skey",
        "windows": "%APPDATA%\\cardano\\payment.skey",
        "macos": "~/Library/Application Support/cardano/payment.skey",
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete ADA honeypot artifact bundle."""
    keypair = generate_ada_keypair()

    ada_dir = output_dir / "ada"
    skey_file = create_skey_artifact(keypair, ada_dir)
    vkey_file = create_vkey_artifact(keypair, ada_dir)

    return {
        "chain": "ada",
        "address_hex": keypair.address_hex,
        "private_key_hex": keypair.private_key_hex,
        "public_key_hex": keypair.public_key_hex,
        "artifact_files": {
            "signing_key": str(skey_file),
            "verification_key": str(vkey_file),
        },
        "default_paths": get_default_paths(),
    }
