#!/bin/sh
set -e

CODEQL_HOME=/usr/local/codeql-home
CODEQL_TAG=""
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
    echo "Checking version"

    # Set the codeql version to the latest if it is not provided
    if [ "$CODEQL_VERSION" = "latest" ]; then
        CODEQL_TAG=$(curl -s https://api.github.com/repos/github/codeql-action/releases/latest | jq -r '.tag_name')
        echo "Setting the CodeQL version to the latest: $CODEQL_TAG"
    else
        CODEQL_TAG="codeql-bundle-v$CODEQL_VERSION"
        echo "Using provided version: $CODEQL_TAG"
    fi
}

install_packages() {
    echo "Installing required packages"

    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        jq

    echo "Installed packages:"
    curl --version
    jq --version
}

install_codeql() {    
    echo "Installing CodeQL"
    mkdir ${CODEQL_HOME}

    # Install CodeQL
    cd /tmp 

    echo "Downloading CodeQL bundle v${CODEQL_TAG}"
    curl -OL https://github.com/github/codeql-action/releases/download/${CODEQL_TAG}/codeql-bundle-linux64.tar.gz
    tar -xvf /tmp/codeql-bundle-linux64.tar.gz --directory ${CODEQL_HOME} 
    rm /tmp/codeql-bundle-linux64.tar.gz
}

install_packages

check_version

install_codeql