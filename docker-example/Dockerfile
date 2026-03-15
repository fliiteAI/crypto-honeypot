FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    auditd \
    curl \
    sed \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install the honeypot-deployer
RUN pip install --no-cache-dir .

# Copy entrypoint script
COPY docker-example/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment variables
ENV MANIFEST_PASSWORD=""
ENV NODE_NAME="docker-honeypot-agent"

ENTRYPOINT ["/entrypoint.sh"]
