# Dockerfile for Crypto Wallet Honeypot Demo
# This builds an environment similar to a compromised developer workstation

FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    auditd \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER developer
WORKDIR /home/developer

# Copy the project files (assumes we are building from the project root)
# In a real scenario, you'd mount this or clone it
COPY --chown=developer:developer . /home/developer/honeypot

# Install the honeypot deployer
WORKDIR /home/developer/honeypot
RUN pip3 install .

# Run the deployment script to set up artifacts
RUN ./deploy.sh

# The container will stay running to allow manual testing
CMD ["tail", "-f", "/dev/null"]
