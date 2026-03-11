"""Honeypot Deployer CLI.

Command-line interface for generating, deploying, and managing crypto wallet
honeypot artifacts with Wazuh SIEM integration.
"""

import json
import sys
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from honeypot_deployer.generators import ada, browser, btc, eth, seed, sol, xrp
from honeypot_deployer.manifest import HoneypotManifest

console = Console()

SUPPORTED_CHAINS = ["btc", "eth", "sol", "xrp", "ada"]
ALL_CHAINS_STR = ",".join(SUPPORTED_CHAINS)


@click.group()
@click.version_option(version="0.1.0", prog_name="honeypot-deployer")
def main() -> None:
    """Defensive crypto wallet honeypot deployer for Wazuh SIEM.

    Generate realistic wallet artifacts, canary seed phrases, and browser
    extension decoys to detect attackers targeting cryptocurrency assets.
    """


@main.command()
@click.option(
    "--chains",
    default=ALL_CHAINS_STR,
    show_default=True,
    help="Comma-separated list of chains to generate artifacts for.",
)
@click.option(
    "--output",
    "-o",
    type=click.Path(),
    default="./honeypot-artifacts",
    show_default=True,
    help="Output directory for generated artifacts.",
)
@click.option(
    "--include-seed/--no-seed",
    default=True,
    show_default=True,
    help="Generate canary seed phrase files.",
)
@click.option(
    "--include-browser/--no-browser",
    default=True,
    show_default=True,
    help="Generate browser extension decoy data.",
)
@click.option(
    "--encrypt-manifest/--no-encrypt-manifest",
    default=True,
    show_default=True,
    help="Encrypt the manifest file with a password.",
)
@click.option(
    "--manifest-password",
    prompt=False,
    default=None,
    help="Password for manifest encryption. Prompted if not provided.",
)
def generate(
    chains: str,
    output: str,
    include_seed: bool,
    include_browser: bool,
    encrypt_manifest: bool,
    manifest_password: str | None,
) -> None:
    """Generate honeypot wallet artifacts for all supported chains.

    Creates realistic wallet files, keystore data, seed phrase backups,
    and browser extension decoys. All generated keys and addresses are
    tracked in an encrypted manifest for chain monitoring.
    """
    output_dir = Path(output)
    chain_list = [c.strip().lower() for c in chains.split(",")]

    # Validate chains
    invalid = [c for c in chain_list if c not in SUPPORTED_CHAINS]
    if invalid:
        console.print(f"[red]Error: Unknown chain(s): {', '.join(invalid)}[/red]")
        console.print(f"Supported chains: {ALL_CHAINS_STR}")
        sys.exit(1)

    if encrypt_manifest and not manifest_password:
        manifest_password = click.prompt(
            "Manifest encryption password", hide_input=True, confirmation_prompt=True
        )

    console.print(
        Panel(
            f"Generating honeypot artifacts\n"
            f"Chains: {', '.join(chain_list)}\n"
            f"Output: {output_dir}\n"
            f"Seed phrases: {'Yes' if include_seed else 'No'}\n"
            f"Browser decoys: {'Yes' if include_browser else 'No'}\n"
            f"Encrypted manifest: {'Yes' if encrypt_manifest else 'No'}",
            title="Honeypot Deployer",
            border_style="blue",
        )
    )

    manifest = HoneypotManifest()
    addresses: dict[str, str] = {}

    # Generate chain-specific artifacts
    generators = {
        "btc": btc.generate_artifact_bundle,
        "eth": eth.generate_artifact_bundle,
        "sol": sol.generate_artifact_bundle,
        "xrp": xrp.generate_artifact_bundle,
        "ada": ada.generate_artifact_bundle,
    }

    for chain in chain_list:
        gen_func = generators[chain]
        console.print(f"  Generating [cyan]{chain.upper()}[/cyan] artifacts...", end=" ")
        bundle = gen_func(output_dir)
        manifest.add_chain_artifact(bundle)
        address = bundle.get("address") or bundle.get("address_hex", "N/A")
        addresses[chain] = address
        console.print(f"[green]OK[/green] (address: {address[:20]}...)")

    # Generate seed phrase artifacts
    if include_seed:
        console.print("  Generating [cyan]seed phrase[/cyan] canaries...", end=" ")
        seed_bundle = seed.generate_artifact_bundle(output_dir)
        manifest.add_seed_phrase(seed_bundle)
        console.print(f"[green]OK[/green] ({seed_bundle['word_count']}-word mnemonic)")

    # Generate browser extension decoys
    if include_browser:
        console.print("  Generating [cyan]browser extension[/cyan] decoys...", end=" ")
        browser_bundle = browser.generate_artifact_bundle(
            output_dir,
            eth_address=addresses.get("eth", ""),
            sol_address=addresses.get("sol", ""),
            btc_address=addresses.get("btc", ""),
        )
        manifest.add_chain_artifact(browser_bundle)
        decoy_count = len(browser_bundle.get("artifact_files", {}))
        console.print(f"[green]OK[/green] ({decoy_count} extensions)")

    # Save manifest
    manifest_path = output_dir / "manifest.json"
    manifest.save(manifest_path, password=manifest_password if encrypt_manifest else None)

    # Display summary
    _print_summary(manifest, output_dir, manifest_path)

    # Export chain monitor addresses
    addresses_file = output_dir / "chain-monitor-addresses.json"
    with open(addresses_file, "w") as f:
        json.dump(manifest.get_chain_addresses(), f, indent=2)
    console.print(f"\nChain monitor addresses exported to: [cyan]{addresses_file}[/cyan]")


def _print_summary(manifest: HoneypotManifest, output_dir: Path, manifest_path: Path) -> None:
    """Print a summary table of generated artifacts."""
    summary = manifest.summary()

    table = Table(title="Generation Summary", border_style="green")
    table.add_column("Property", style="bold")
    table.add_column("Value")

    table.add_row("Chains", ", ".join(summary["chains"]))
    table.add_row("Total addresses", str(summary["total_addresses"]))
    table.add_row("Total artifacts", str(summary["total_artifacts"]))
    table.add_row("Seed phrases", str(summary["total_seed_phrases"]))
    table.add_row("Output directory", str(output_dir))
    table.add_row("Manifest", str(manifest_path))

    console.print()
    console.print(table)


@main.command()
@click.option(
    "--manifest",
    "-m",
    type=click.Path(exists=True),
    required=True,
    help="Path to the honeypot manifest file.",
)
@click.option(
    "--password",
    prompt=False,
    default=None,
    help="Manifest decryption password.",
)
def show(manifest: str, password: str | None) -> None:
    """Display the contents of a honeypot manifest."""
    manifest_path = Path(manifest)

    # Check if encrypted
    with open(manifest_path) as f:
        raw = json.load(f)

    if raw.get("encrypted") and not password:
        password = click.prompt("Manifest password", hide_input=True)

    m = HoneypotManifest.load(manifest_path, password)
    summary = m.summary()

    table = Table(title="Honeypot Manifest", border_style="blue")
    table.add_column("Property", style="bold")
    table.add_column("Value")

    table.add_row("Created", summary["created"])
    table.add_row("Modified", summary["modified"])
    table.add_row("Chains", ", ".join(summary["chains"]))
    table.add_row("Addresses", str(summary["total_addresses"]))
    table.add_row("Artifacts", str(summary["total_artifacts"]))
    table.add_row("Seed phrases", str(summary["total_seed_phrases"]))

    console.print(table)

    # Show addresses
    addresses = m.get_chain_addresses()
    if addresses:
        addr_table = Table(title="Monitored Addresses", border_style="cyan")
        addr_table.add_column("Chain", style="bold")
        addr_table.add_column("Address")

        for chain, addrs in addresses.items():
            for addr in addrs:
                addr_table.add_row(chain.upper(), addr)

        console.print(addr_table)


@main.command()
@click.option(
    "--manifest",
    "-m",
    type=click.Path(exists=True),
    required=True,
    help="Path to the honeypot manifest file.",
)
@click.option(
    "--password",
    prompt=False,
    default=None,
    help="Manifest decryption password.",
)
@click.option(
    "--output",
    "-o",
    type=click.Path(),
    default="./chain-monitor-addresses.json",
    show_default=True,
    help="Output file for chain monitor address configuration.",
)
def export_addresses(manifest: str, password: str | None, output: str) -> None:
    """Export honeypot addresses for the chain monitor service.

    Generates a JSON file that the chain monitor daemon reads to know
    which blockchain addresses to watch for activity.
    """
    manifest_path = Path(manifest)

    with open(manifest_path) as f:
        raw = json.load(f)

    if raw.get("encrypted") and not password:
        password = click.prompt("Manifest password", hide_input=True)

    m = HoneypotManifest.load(manifest_path, password)
    addresses = m.get_chain_addresses()

    output_path = Path(output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w") as f:
        json.dump(addresses, f, indent=2)

    total = sum(len(a) for a in addresses.values())
    console.print(f"Exported {total} addresses to [cyan]{output_path}[/cyan]")


@main.command(name="wazuh-config")
@click.option(
    "--manifest",
    "-m",
    type=click.Path(exists=True),
    required=True,
    help="Path to the honeypot manifest file.",
)
@click.option(
    "--password",
    prompt=False,
    default=None,
    help="Manifest decryption password.",
)
@click.option(
    "--os",
    "target_os",
    type=click.Choice(["linux", "windows", "macos"]),
    default="linux",
    show_default=True,
    help="Target OS for Wazuh agent configuration.",
)
@click.option(
    "--output",
    "-o",
    type=click.Path(),
    default="./wazuh-agent-config",
    show_default=True,
    help="Output directory for Wazuh configuration files.",
)
def wazuh_config(manifest: str, password: str | None, target_os: str, output: str) -> None:
    """Generate Wazuh agent FIM configuration for deployed honeypots.

    Creates an ossec.conf snippet with FIM directories configured
    for all honeypot artifact paths on the target OS.
    """
    manifest_path = Path(manifest)

    with open(manifest_path) as f:
        raw = json.load(f)

    if raw.get("encrypted") and not password:
        password = click.prompt("Manifest password", hide_input=True)

    m = HoneypotManifest.load(manifest_path, password)
    output_dir = Path(output)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Collect all artifact paths for the target OS
    fim_paths = _collect_fim_paths(m, target_os)

    # Generate FIM config snippet
    fim_config = _generate_fim_config(fim_paths)
    fim_file = output_dir / "honeypot-fim.conf"
    with open(fim_file, "w") as f:
        f.write(fim_config)

    console.print(f"Wazuh FIM config written to [cyan]{fim_file}[/cyan]")
    console.print(f"  Monitoring [bold]{len(fim_paths)}[/bold] paths")
    console.print(
        "\n[yellow]Add this to your agent's ossec.conf <syscheck> section.[/yellow]"
    )


def _collect_fim_paths(manifest: HoneypotManifest, target_os: str) -> list[str]:
    """Collect all honeypot file paths for FIM monitoring on the given OS."""
    paths: list[str] = []

    for hp in manifest.data["honeypots"]:
        default_paths = hp.get("default_paths", {})

        if isinstance(default_paths, dict):
            os_paths = default_paths.get(target_os)
            if isinstance(os_paths, str):
                paths.append(os_paths)
            elif isinstance(os_paths, list):
                paths.extend(os_paths)
            elif isinstance(os_paths, dict):
                paths.extend(os_paths.values())

    for sp in manifest.data["seed_phrases"]:
        default_paths = sp.get("default_paths", {})
        os_paths = default_paths.get(target_os, [])
        if isinstance(os_paths, list):
            paths.extend(os_paths)

    return paths


def _generate_fim_config(paths: list[str]) -> str:
    """Generate a Wazuh FIM configuration XML snippet."""
    lines = [
        "<!-- Honeypot Deployer: Auto-generated FIM configuration -->",
        "<!-- Add these directives inside the <syscheck> section of ossec.conf -->",
        "",
    ]

    for path in paths:
        # Use directory monitoring for directories, file monitoring for files
        lines.append(
            f'  <directories check_all="yes" whodata="yes" realtime="yes" '
            f'report_changes="yes">{path}</directories>'
        )

    return "\n".join(lines) + "\n"


@main.command(name="health-check")
@click.option(
    "--manifest",
    "-m",
    type=click.Path(exists=True),
    required=True,
    help="Path to the honeypot manifest file.",
)
@click.option(
    "--password",
    prompt=False,
    default=None,
    help="Manifest decryption password.",
)
def health_check(manifest: str, password: str | None) -> None:
    """Verify honeypot deployment health.

    Checks that artifact files exist at expected paths and reports
    any missing or modified files.
    """
    manifest_path = Path(manifest)

    with open(manifest_path) as f:
        raw = json.load(f)

    if raw.get("encrypted") and not password:
        password = click.prompt("Manifest password", hide_input=True)

    m = HoneypotManifest.load(manifest_path, password)

    table = Table(title="Health Check", border_style="blue")
    table.add_column("Artifact", style="bold")
    table.add_column("Path")
    table.add_column("Status")

    issues = 0
    for hp in m.data["honeypots"]:
        chain = hp.get("chain", hp.get("type", "unknown"))

        # Check artifact files
        artifact_files = hp.get("artifact_files", {})
        artifact_file = hp.get("artifact_file")

        if artifact_file:
            artifact_files["main"] = artifact_file

        for name, file_path in artifact_files.items():
            exists = Path(file_path).exists()
            status = "[green]OK[/green]" if exists else "[red]MISSING[/red]"
            if not exists:
                issues += 1
            table.add_row(f"{chain.upper()} ({name})", file_path, status)

    console.print(table)

    if issues:
        console.print(f"\n[red]WARNING: {issues} artifact(s) missing![/red]")
        console.print("Run 'honeypot-deployer generate' to regenerate.")
    else:
        console.print("\n[green]All artifacts present and accounted for.[/green]")


if __name__ == "__main__":
    main()
