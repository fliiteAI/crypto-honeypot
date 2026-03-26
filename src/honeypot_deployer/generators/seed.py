"""Canary seed phrase generation and artifact creation.

Generates valid BIP-39 mnemonics and places them in locations attackers typically
search: Documents, Desktop, hidden config files, etc.
"""

import json
import time
from dataclasses import dataclass, field
from pathlib import Path

from mnemonic import Mnemonic


@dataclass
class SeedPhraseBundle:
    """A canary seed phrase with derived addresses for monitoring."""

    mnemonic: str
    word_count: int
    derived_addresses: dict[str, str] = field(default_factory=dict)


def generate_seed_phrase(word_count: int = 24) -> SeedPhraseBundle:
    """Generate a valid BIP-39 mnemonic seed phrase.

    Args:
        word_count: Number of words (12 or 24). Default 24 for realism.

    Returns:
        SeedPhraseBundle with the mnemonic and placeholder for derived addresses.
    """
    if word_count not in (12, 24):
        raise ValueError("word_count must be 12 or 24")

    strength = 128 if word_count == 12 else 256
    m = Mnemonic("english")
    mnemonic = m.generate(strength)

    return SeedPhraseBundle(
        mnemonic=mnemonic,
        word_count=word_count,
    )


def create_seed_txt_artifact(bundle: SeedPhraseBundle, output_path: Path) -> Path:
    """Create a plain-text seed backup file.

    Looks like a user's hand-typed seed phrase backup.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    seed_file = output_path / "seed-backup.txt"
    seed_file.parent.mkdir(parents=True, exist_ok=True)
    words = bundle.mnemonic.split()
    numbered_words = "\n".join(f"  {i + 1}. {word}" for i, word in enumerate(words))

    content = f"""=== CRYPTO WALLET RECOVERY SEED ===
=== DO NOT LOSE THIS FILE ===

Created: {time.strftime("%B %d, %Y")}
Wallet: Main Portfolio

Recovery Seed Phrase ({bundle.word_count} words):
{numbered_words}

IMPORTANT:
- Store this in a safe place
- Never share with anyone
- Required to recover wallet if device is lost

Passphrase: (none)
"""
    with open(seed_file, "w") as f:
        f.write(content)

    return seed_file


def create_hidden_seed_artifact(bundle: SeedPhraseBundle, output_path: Path) -> Path:
    """Create a hidden dotfile containing a seed phrase.

    Simulates a tech-savvy user hiding their seed in a config directory.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    hidden_file = output_path / ".seed_phrase"
    hidden_file.parent.mkdir(parents=True, exist_ok=True)
    content = f"""# wallet recovery - {time.strftime("%Y-%m-%d")}
{bundle.mnemonic}
"""
    with open(hidden_file, "w") as f:
        f.write(content)

    return hidden_file


def create_notes_artifact(bundle: SeedPhraseBundle, output_path: Path) -> Path:
    """Create a notes.txt file with seed phrase buried in other content.

    Simulates a user who jotted down their seed phrase in a general notes file.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    notes_file = output_path / "notes.txt"
    notes_file.parent.mkdir(parents=True, exist_ok=True)
    content = f"""Shopping list:
- Milk
- Bread
- Coffee

WiFi password: Sunshine2024!

Crypto seed:
{bundle.mnemonic}

PIN: 4829

Netflix: user@email.com / StreamPass99

Dentist appointment: March 15 at 2pm
"""
    with open(notes_file, "w") as f:
        f.write(content)

    return notes_file


def create_json_backup_artifact(bundle: SeedPhraseBundle, output_path: Path) -> Path:
    """Create a JSON wallet backup file.

    Mimics automated wallet backup exports.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    backup_file = output_path / "wallet-backup.json"
    backup_file.parent.mkdir(parents=True, exist_ok=True)
    backup_data = {
        "version": "2.0",
        "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "wallet_name": "Main Portfolio",
        "type": "mnemonic",
        "seed_phrase": bundle.mnemonic,
        "word_count": bundle.word_count,
        "passphrase": "",
        "networks": ["bitcoin", "ethereum", "solana"],
        "note": "Auto-generated backup. Keep in a safe location.",
    }

    with open(backup_file, "w") as f:
        json.dump(backup_data, f, indent=2)

    return backup_file


def get_default_paths() -> dict[str, list[str]]:
    """Return default seed phrase file placement paths."""
    return {
        "linux": [
            "~/Documents/seed-backup.txt",
            "~/Desktop/crypto-recovery.txt",
            "~/.config/.seed_phrase",
            "~/notes.txt",
            "~/Documents/wallet-backup.json",
        ],
        "windows": [
            "%USERPROFILE%\\Documents\\seed-backup.txt",
            "%USERPROFILE%\\Desktop\\crypto-recovery.txt",
            "%APPDATA%\\.seed_phrase",
            "%USERPROFILE%\\notes.txt",
            "%USERPROFILE%\\Documents\\wallet-backup.json",
        ],
        "macos": [
            "~/Documents/seed-backup.txt",
            "~/Desktop/crypto-recovery.txt",
            "~/.config/.seed_phrase",
            "~/notes.txt",
            "~/Documents/wallet-backup.json",
        ],
    }


def generate_artifact_bundle(output_dir: Path) -> dict:
    """Generate a complete seed phrase honeypot artifact bundle."""
    bundle = generate_seed_phrase(word_count=24)

    seed_dir = output_dir / "seed"
    txt_file = create_seed_txt_artifact(bundle, seed_dir)
    hidden_file = create_hidden_seed_artifact(bundle, seed_dir)
    notes_file = create_notes_artifact(bundle, seed_dir)
    json_file = create_json_backup_artifact(bundle, seed_dir)

    return {
        "type": "seed_phrase",
        "mnemonic": bundle.mnemonic,
        "word_count": bundle.word_count,
        "derived_addresses": bundle.derived_addresses,
        "artifact_files": {
            "seed_txt": str(txt_file),
            "hidden_seed": str(hidden_file),
            "notes": str(notes_file),
            "json_backup": str(json_file),
        },
        "default_paths": get_default_paths(),
    }
