FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    auditd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pyproject.toml .
COPY README.md .
COPY src/ ./src/
COPY deploy.sh .

# Install the honeypot-deployer
RUN pip install --no-cache-dir .

# Create a non-root user for the honeypot
RUN useradd -m honeypotuser
USER honeypotuser
WORKDIR /home/honeypotuser

# Initialize honeypots on startup
# Using the standalone script to demonstrate its use in a container
CMD ["/bin/bash", "/app/deploy.sh"]
