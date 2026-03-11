"""Honeypot manifest/inventory management.

Tracks all generated honeypot keypairs, addresses, and artifact locations.
The manifest is the single source of truth for what's deployed and what
the chain monitor should watch.
"""

import base64
import json
import os
import time
from pathlib import Path
from typing import Any

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def _derive_key(password: str, salt: bytes) -> bytes:
    """Derive an encryption key from a password using PBKDF2."""
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=600_000,
    )
    return base64.urlsafe_b64encode(kdf.derive(password.encode("utf-8")))


class HoneypotManifest:
    """Manages the honeypot deployment manifest.

    The manifest stores all generated keys, addresses, and deployment metadata.
    It can be encrypted at rest with a password.
    """

    def __init__(self) -> None:
        self.data: dict[str, Any] = {
            "version": "1.0",
            "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "modified": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "honeypots": [],
            "chain_addresses": {},
            "seed_phrases": [],
        }

    def add_chain_artifact(self, chain_data: dict) -> None:
        """Add a chain-specific artifact entry to the manifest."""
        chain = chain_data.get("chain", chain_data.get("type", "unknown"))

        self.data["honeypots"].append({
            "id": f"hp-{chain}-{int(time.time())}",
            "chain": chain,
            "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            **chain_data,
        })

        # Track addresses for chain monitor
        address = chain_data.get("address") or chain_data.get("address_hex")
        if address and chain not in ("seed_phrase", "browser_decoys"):
            if chain not in self.data["chain_addresses"]:
                self.data["chain_addresses"][chain] = []
            self.data["chain_addresses"][chain].append(address)

    def add_seed_phrase(self, seed_data: dict) -> None:
        """Add a seed phrase entry to the manifest."""
        self.data["seed_phrases"].append({
            "id": f"seed-{int(time.time())}",
            "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            **seed_data,
        })

    def get_chain_addresses(self) -> dict[str, list[str]]:
        """Return all monitored addresses grouped by chain."""
        return dict(self.data["chain_addresses"])

    def save(self, path: Path, password: str | None = None) -> Path:
        """Save the manifest to disk, optionally encrypted.

        Args:
            path: Output file path.
            password: If provided, encrypt the manifest with this password.

        Returns:
            The path the manifest was saved to.
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        self.data["modified"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

        json_bytes = json.dumps(self.data, indent=2).encode("utf-8")

        if password:
            salt = os.urandom(16)
            key = _derive_key(password, salt)
            fernet = Fernet(key)
            encrypted = fernet.encrypt(json_bytes)

            envelope = {
                "encrypted": True,
                "algorithm": "Fernet (AES-128-CBC + HMAC-SHA256)",
                "kdf": "PBKDF2-SHA256",
                "iterations": 600_000,
                "salt": base64.b64encode(salt).decode("ascii"),
                "data": encrypted.decode("ascii"),
            }
            with open(path, "w") as f:
                json.dump(envelope, f, indent=2)
        else:
            with open(path, "w") as f:
                f.write(json_bytes.decode("utf-8"))

        return path

    @classmethod
    def load(cls, path: Path, password: str | None = None) -> "HoneypotManifest":
        """Load a manifest from disk, optionally decrypting it.

        Args:
            path: Path to the manifest file.
            password: Required if the manifest is encrypted.

        Returns:
            A HoneypotManifest instance.
        """
        with open(path) as f:
            raw = json.load(f)

        if raw.get("encrypted"):
            if not password:
                raise ValueError("Manifest is encrypted but no password provided")

            salt = base64.b64decode(raw["salt"])
            key = _derive_key(password, salt)
            fernet = Fernet(key)
            decrypted = fernet.decrypt(raw["data"].encode("ascii"))
            data = json.loads(decrypted)
        else:
            data = raw

        manifest = cls()
        manifest.data = data
        return manifest

    def summary(self) -> dict:
        """Return a summary of the manifest for display."""
        chains = list(self.data["chain_addresses"].keys())
        total_addresses = sum(
            len(addrs) for addrs in self.data["chain_addresses"].values()
        )
        total_artifacts = len(self.data["honeypots"])
        total_seeds = len(self.data["seed_phrases"])

        return {
            "chains": chains,
            "total_addresses": total_addresses,
            "total_artifacts": total_artifacts,
            "total_seed_phrases": total_seeds,
            "created": self.data["created"],
            "modified": self.data["modified"],
        }
