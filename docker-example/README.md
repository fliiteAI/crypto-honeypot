# Containerized Wazuh Agent with Honeypot

This example demonstrates how to run the Wazuh agent in a Docker container with automated honeypot artifact generation and FIM configuration.

## Prerequisites

To support high-fidelity `whodata` monitoring (via `auditd`) within the container, you must run it with host privileges:

- `--cap-add=AUDIT_CONTROL`
- `--pid=host`

## Usage

### 1. Build the image
```bash
docker build -t wazuh-agent-honeypot -f docker-example/Dockerfile .
```

### 2. Run the container
```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e WAZUH_AGENT_NAME="my-container-agent" \
  -v /var/lib/honeypot:/var/lib/honeypot \
  wazuh-agent-honeypot
```

## How it works

1. The `entrypoint.sh` script checks if honeypot artifacts exist in `/var/lib/honeypot`. If not, it generates them using the `honeypot-deployer` CLI.
2. It generates a Wazuh FIM configuration snippet tailored to the generated artifacts.
3. It robustly injects an `<include>` statement into the Wazuh agent's `/var/ossec/etc/ossec.conf`.
4. It starts the Wazuh agent process.

## Persistence

The honeypot manifest and artifacts are stored in the `/var/lib/honeypot` volume. This ensures that the same honeypot identities are maintained across container restarts.
