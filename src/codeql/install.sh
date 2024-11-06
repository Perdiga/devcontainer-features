#!/bin/sh
set -e

CODEQL_HOME=/usr/local/codeql-home

echo "Activating feature 'CodeQL'"
echo "The provided CodeQL version is: $CODEQL_VERSION"
echo "The CodeQL home directory is: $CODEQL_HOME"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

check_version() {
    echo "Checking if the provided version is valid"

}

install_packages() {
    echo "Installing required packages"

    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        curl \
        git \
        git-lfs \
        build-essential \
        unzip \
        apt-transport-https \
        python3.10 \
        python3-venv \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python-is-python3 \
        gnupg \
        g++ \
        make \
        gcc \
        apt-utils 

    # Clean up
    apt-get clean && apt-get autoremove
}

install_codeql() {    
    echo "Installing CodeQL"
    mkdir ${CODEQL_HOME}

    # Install CodeQL
    cd /tmp 

    echo "Downloading CodeQL bundle v${CODEQL_VERSION}"
    curl -OL https://github.com/github/codeql-action/releases/download/codeql-bundle-v${CODEQL_VERSION}/codeql-bundle-linux64.tar.gz
    tar -xvf /tmp/codeql-bundle-linux64.tar.gz --directory ${CODEQL_HOME} 
    rm /tmp/codeql-bundle-linux64.tar.gz
}

check_version

install_packages

install_codeql