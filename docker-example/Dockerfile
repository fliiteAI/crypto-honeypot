FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for deploy.sh
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the deployment script from the parent directory
# Note: When building with docker-compose, the context should be the root of the repo
COPY deploy.sh .

# Create a non-root user to simulate a target environment
RUN useradd -m crypto-user
USER crypto-user
WORKDIR /home/crypto-user

# Run the deployment script to create honeyfiles
# We copy it here so the crypto-user can run it in their home
COPY --chown=crypto-user:crypto-user deploy.sh .
RUN chmod +x deploy.sh && ./deploy.sh

# Keep the container running
CMD ["tail", "-f", "/dev/null"]
