# Base image
FROM ubuntu:20.04

# Set the GitHub runner version
ARG RUNNER_VERSION="2.317.0"

# Update the base packages
RUN apt-get update -y && apt-get upgrade -y

# Install dependencies
RUN apt-get install -y --no-install-suggests --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    build-essential

# Create a directory for the GitHub Actions runner
RUN mkdir -p /home/docker/actions-runner
WORKDIR /home/docker/actions-runner

# Download the latest runner package
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install dependencies for the runner
RUN /home/docker/actions-runner/bin/installdependencies.sh

# Copy the start script
COPY start.sh /home/docker/actions-runner/start.sh

# Make the start script executable
RUN chmod +x /home/docker/actions-runner/start.sh

# Set the entrypoint to the start script
ENTRYPOINT ["/home/docker/actions-runner/start.sh"]
