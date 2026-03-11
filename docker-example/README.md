# Crypto Honeypot Docker Example

This directory contains an example of how to deploy the crypto wallet honeyfiles within an isolated Docker container. This is useful for creating "sacrificial" nodes in your network that are designed specifically to attract and detect attackers.

## Files
- `Dockerfile`: Builds an Ubuntu-based image and runs the `deploy.sh` script.
- `docker-compose.yml`: Simple orchestration for the honey-container.

## Usage

1. **Build and Start the Container:**
   From this directory, run:
   ```bash
   docker compose up -d --build
   ```

2. **Verify Honeyfiles:**
   You can check that the files were created in the container:
   ```bash
   docker exec -it crypto-honey-node ls -laR /home/crypto-user
   ```

## Wazuh Integration in Docker

To monitor this container with Wazuh, you have several options:

### Option 1: Install Wazuh Agent in the Container
Modify the `Dockerfile` to include the Wazuh agent installation and configuration.

### Option 2: Monitor via Docker Socket
Configure your host's Wazuh agent to monitor the Docker socket for container events and log collection.

### Option 3: Volume Mount Logs
If you modify `deploy.sh` to log honeyfile access to a specific file, you can mount that log file to the host and have the host's Wazuh agent monitor it.

## Limitations
- **Auditd:** Running `auditd` inside a standard Docker container is difficult as it requires privileged mode and interacts with the host's kernel. For high-fidelity read-access detection, it is recommended to deploy on a virtual machine or physical host.
