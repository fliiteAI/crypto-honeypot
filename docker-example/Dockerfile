FROM wazuh/wazuh-agent:4.7.2

# Install dependencies for honeypot-deployer
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    auditd \
    && rm -rf /var/lib/apt/lists/*

# Copy the honeypot-deployer source
COPY . /opt/honeypot-deployer
WORKDIR /opt/honeypot-deployer

# Install the honeypot-deployer CLI
RUN pip3 install .

# Setup entrypoint script
COPY docker-example/entrypoint.sh /usr/local/bin/entrypoint-honeypot.sh
RUN chmod +x /usr/local/bin/entrypoint-honeypot.sh

# The container must be run with --cap-add=AUDIT_CONTROL and --pid=host
# to allow the Wazuh agent to interact with auditd on the host.

ENTRYPOINT ["/usr/local/bin/entrypoint-honeypot.sh"]
