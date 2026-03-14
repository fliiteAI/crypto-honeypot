# Dockerfile for Crypto Wallet Honeypot Agent
# This container runs a Wazuh Agent and deploys honeypot artifacts.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    python3 \
    python3-pip \
    auditd \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Wazuh Agent
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y wazuh-agent

# Copy honeypot deployer code
WORKDIR /opt/honeypot
COPY . .

# Install the deployer
RUN pip3 install .

# Setup entrypoint to configure agent and deploy honeypots
COPY docker-example/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
