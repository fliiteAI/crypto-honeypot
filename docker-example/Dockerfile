# Dockerfile for Honeypot-Enabled Wazuh Agent
FROM wazuh/wazuh-agent:4.7.2

USER root

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    auditd \
    && rm -rf /var/lib/apt/lists/*

# Install the honeypot deployer
WORKDIR /app
COPY . /app
RUN pip3 install /app

# Copy entrypoint script
COPY docker-example/entrypoint.sh /entrypoint-honeypot.sh
RUN chmod +x /entrypoint-honeypot.sh

ENTRYPOINT ["/entrypoint-honeypot.sh"]
