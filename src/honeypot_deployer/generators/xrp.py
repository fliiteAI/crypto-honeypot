"""XRP (Ripple) honeypot wallet key generation and artifact creation."""

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import ecdsa


@dataclass
class XRPKeypair:
    """An XRP keypair for honeypot deployment."""

    private_key_hex: str
    public_key_hex: str
    address: str  # Classic XRP address (r...)


def _sha256(data: bytes) -> bytes:
    return hashlib.sha256(data).digest()


def _ripemd160(data: bytes) -> bytes:
    h = hashlib.new("ripemd160")
    h.update(data)
    return h.digest()


def _xrp_address_from_pubkey(public_key_bytes: bytes) -> str:
    """Derive an XRP classic address from a compressed public key.

    XRP uses the same HASH160 (SHA-256 -> RIPEMD-160) as Bitcoin,
    but with a different Base58 alphabet and a version byte of 0x00.
    """
    xrp_alphabet = b"rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz"

    account_id = _ripemd160(_sha256(public_key_bytes))

    # Version byte 0x00 for XRP mainnet
    payload = b"\x00" + account_id
    checksum = _sha256(_sha256(payload))[:4]
    raw = payload + checksum

    # XRP uses its own Base58 alphabet
    result = []
    value = int.from_bytes(raw, "big")
    while value > 0:
        value, remainder = divmod(value, 58)
        result.append(xrp_alphabet[remainder:remainder + 1])

    # Handle leading zeros
    for byte in raw:
        if byte == 0:
            result.append(xrp_alphabet[0:1])
        else:
            break

    return b"".join(reversed(result)).decode("ascii")


def generate_xrp_keypair() -> XRPKeypair:
    """Generate a new XRP keypair suitable for honeypot use.

    Uses secp256k1 (the default XRP key type).
    """
    signing_key = ecdsa.SigningKey.generate(curve=ecdsa.SECP256k1)
    private_key_bytes = signing_key.to_string()
    private_key_hex = private_key_bytes.hex()

    # Compressed public key
    verifying_key = signing_key.get_verifying_key()
    pub_point = verifying_key.to_string()
    x = pub_point[:32]
    y = pub_point[32:]
    prefix = b"\x02" if y[-1] % 2 == 0 else b"\x03"
    compressed_pub = prefix + x
    public_key_hex = compressed_pub.hex()

    address = _xrp_address_from_pubkey(compressed_pub)

    return XRPKeypair(
        private_key_hex=private_key_hex,
        public_key_hex=public_key_hex,
        address=address,
    )


def create_wallet_export_artifact(keypair: XRPKeypair, output_path: Path) -> Path:
    """Create a realistic XRP wallet export JSON file.

    Mimics the format exported by popular XRP wallets like XUMM/Xaman.
    """
    output_path.mkdir(parents=True, exist_ok=True)

    wallet_file = output_path / "xrp-wallet-backup.json"
    wallet_data = {
        "wallet_name": "Main XRP Wallet",
        "exported_at": "2025-12-15T10:30:00Z",
        "network": "mainnet",
        "account": {
            "address": keypair.address,
            "public_key": keypair.public_key_hex,
            "secret_key": keypair.private_key_hex,
            "key_type": "secp256k1",
        },
        "settings": {
            "default_fee": "12",
            "default_destination_tag": None,
            "require_destination_tag": False,
        },
        "notes": "Primary wallet - DO NOT SHARE",
    }

    with open(wallet_file, "w") as f:
        json.dump(wallet_data, f, indent=2)

    return wallet_file


def get_default_paths() -> dict[str, str]:
    """Return default XRP wallet placement paths."""
    return {
        "linux": "~/Documents/xrp-wallet-backup.json",
        "windows": "%USERPROFILE%\\Documents\\xrp-wallet-backup.json",
        "macos": "~/Documents/xrp-wallet-backup.json",
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete XRP honeypot artifact bundle."""
    keypair = generate_xrp_keypair()

    xrp_dir = output_dir / "xrp"
    wallet_file = create_wallet_export_artifact(keypair, xrp_dir)

    return {
        "chain": "xrp",
        "address": keypair.address,
        "private_key_hex": keypair.private_key_hex,
        "public_key_hex": keypair.public_key_hex,
        "artifact_files": {
            "wallet_export": str(wallet_file),
        },
        "default_paths": get_default_paths(),
    }
