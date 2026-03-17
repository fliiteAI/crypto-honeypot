FROM wazuh/wazuh-agent:4.7.2

# Install Python and dependencies for the honeypot-deployer
USER root
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    auditd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install the honeypot-deployer
WORKDIR /opt/honeypot-deployer
COPY . .
RUN pip3 install .

# Set up the entrypoint
COPY docker-example/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
