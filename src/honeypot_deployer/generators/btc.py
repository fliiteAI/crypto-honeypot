"""Bitcoin honeypot wallet key generation and artifact creation."""

import hashlib
import os
import struct
import time
from dataclasses import dataclass
from pathlib import Path

import base58
import ecdsa


@dataclass
class BTCKeypair:
    """A Bitcoin keypair for honeypot deployment."""

    private_key_hex: str
    private_key_wif: str
    public_key_hex: str
    address: str  # Bech32 (bc1q...) or legacy


def _ripemd160(data: bytes) -> bytes:
    """Compute RIPEMD-160 hash."""
    h = hashlib.new("ripemd160")
    h.update(data)
    return h.digest()


def _sha256(data: bytes) -> bytes:
    """Compute SHA-256 hash."""
    return hashlib.sha256(data).digest()


def _hash160(data: bytes) -> bytes:
    """Compute HASH160 (SHA-256 then RIPEMD-160)."""
    return _ripemd160(_sha256(data))


def _base58check_encode(version: int, payload: bytes) -> str:
    """Base58Check encode with version byte."""
    versioned = bytes([version]) + payload
    checksum = _sha256(_sha256(versioned))[:4]
    return base58.b58encode(versioned + checksum).decode("ascii")


def _bech32_polymod(values: list[int]) -> int:
    """Internal function for Bech32 encoding."""
    generator = [0x3B6A57B2, 0x26508E6D, 0x1EA119FA, 0x3D4233DD, 0x2A1462B3]
    chk = 1
    for value in values:
        top = chk >> 25
        chk = (chk & 0x1FFFFFF) << 5 ^ value
        for i in range(5):
            chk ^= generator[i] if ((top >> i) & 1) else 0
    return chk


def _bech32_hrp_expand(hrp: str) -> list[int]:
    """Expand the HRP for Bech32 checksum computation."""
    return [ord(x) >> 5 for x in hrp] + [0] + [ord(x) & 31 for x in hrp]


def _bech32_create_checksum(hrp: str, data: list[int]) -> list[int]:
    """Compute Bech32 checksum."""
    values = _bech32_hrp_expand(hrp) + data
    polymod = _bech32_polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
    return [(polymod >> 5 * (5 - i)) & 31 for i in range(6)]


def _bech32_encode(hrp: str, witver: int, witprog: bytes) -> str:
    """Encode a segwit address in Bech32 format."""
    charset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    # Convert witness program to 5-bit groups
    data_5bit: list[int] = []
    acc = 0
    bits = 0
    for byte in witprog:
        acc = (acc << 8) | byte
        bits += 8
        while bits >= 5:
            bits -= 5
            data_5bit.append((acc >> bits) & 31)
    if bits > 0:
        data_5bit.append((acc << (5 - bits)) & 31)

    ret = [witver] + data_5bit
    checksum = _bech32_create_checksum(hrp, ret)
    return hrp + "1" + "".join(charset[d] for d in ret + checksum)


def generate_btc_keypair() -> BTCKeypair:
    """Generate a new Bitcoin keypair suitable for honeypot use."""
    # Generate private key using ECDSA secp256k1
    signing_key = ecdsa.SigningKey.generate(curve=ecdsa.SECP256k1)
    private_key_bytes = signing_key.to_string()
    private_key_hex = private_key_bytes.hex()

    # WIF encoding (mainnet, compressed)
    wif_payload = private_key_bytes + b"\x01"  # compressed flag
    private_key_wif = _base58check_encode(0x80, wif_payload)

    # Compressed public key
    verifying_key = signing_key.get_verifying_key()
    pub_point = verifying_key.to_string()
    x = pub_point[:32]
    y = pub_point[32:]
    prefix = b"\x02" if y[-1] % 2 == 0 else b"\x03"
    compressed_pub = prefix + x
    public_key_hex = compressed_pub.hex()

    # Native SegWit address (bc1q...)
    pubkey_hash = _hash160(compressed_pub)
    address = _bech32_encode("bc1", 0, pubkey_hash)

    return BTCKeypair(
        private_key_hex=private_key_hex,
        private_key_wif=private_key_wif,
        public_key_hex=public_key_hex,
        address=address,
    )


def create_wallet_dat_artifact(keypair: BTCKeypair, output_path: Path) -> Path:
    """Create a realistic-looking wallet.dat artifact.

    This creates a minimal binary file that mimics the structure of a Bitcoin Core
    wallet.dat file (Berkeley DB format header + key data). It is NOT a valid
    Berkeley DB file but will appear realistic to automated scanners and manual
    inspection.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Berkeley DB magic number and header
    bdb_magic = b"\x00\x05\x31\x62"  # Berkeley DB btree magic
    bdb_version = struct.pack("<I", 9)  # DB version 9
    page_size = struct.pack("<I", 4096)

    # Construct a minimal header that looks like a real wallet.dat
    header = bytearray(4096)
    header[12:16] = bdb_magic
    header[16:20] = bdb_version
    header[20:24] = page_size
    header[24:28] = struct.pack("<I", 0x20)  # flags
    header[72:76] = struct.pack("<I", int(time.time()))  # creation timestamp

    # Embed key material markers that infostealers look for
    # "name" key format used by Bitcoin Core
    name_key = b"\x04name" + keypair.address.encode("utf-8")
    key_entry = b"\x03key" + bytes.fromhex(keypair.public_key_hex)

    # Place entries at realistic offsets
    offset = 256
    header[offset : offset + len(name_key)] = name_key
    offset += len(name_key) + 32
    header[offset : offset + len(key_entry)] = key_entry

    # Add some realistic padding with wallet metadata patterns
    metadata_markers = [
        b"bestblock",
        b"defaultkey",
        b"minversion",
        b"tx",
        b"version",
        b"ckey",
        b"mkey",
        b"keymeta",
    ]
    offset = 1024
    for marker in metadata_markers:
        if offset + len(marker) + 16 < 4096:
            header[offset : offset + len(marker)] = marker
            offset += len(marker) + 48  # gap between entries

    # Write additional pages with random-looking data to bulk up the file
    additional_pages = os.urandom(4096 * 3)  # 3 more pages

    with open(output_path, "wb") as f:
        f.write(bytes(header))
        f.write(additional_pages)

    return output_path


def get_default_paths() -> dict[str, str]:
    """Return default wallet.dat placement paths per OS."""
    return {
        "linux": "~/.bitcoin/wallets/wallet.dat",
        "windows": "%APPDATA%\\Bitcoin\\wallets\\wallet.dat",
        "macos": "~/Library/Application Support/Bitcoin/wallets/wallet.dat",
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete BTC honeypot artifact bundle.

    Returns a manifest dict with keypair info and artifact paths.
    """
    keypair = generate_btc_keypair()
    wallet_path = output_dir / "btc" / "wallet.dat"
    create_wallet_dat_artifact(keypair, wallet_path)

    return {
        "chain": "btc",
        "address": keypair.address,
        "private_key_wif": keypair.private_key_wif,
        "public_key_hex": keypair.public_key_hex,
        "artifact_file": str(wallet_path),
        "default_paths": get_default_paths(),
    }
