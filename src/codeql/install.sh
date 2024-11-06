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
    if [ -z "$1" ]; then
        echo "Version is not provided"
        exit 1
    fi

    if ! [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Version is not valid. Please provide a valid version"
        exit 1
    fi
}

install_codeql(){    
    mkdir ${CODEQL_HOME}

    # Install CodeQL
    cd /tmp 

    echo "Downloading CodeQL bundle v${$CODEQL_VERSION}"
    curl -OL https://github.com/github/codeql-action/releases/download/codeql-bundle-v${$CODEQL_VERSION}/codeql-bundle-linux64.tar.gz
    tar -xvf /tmp/codeql-bundle-linux64.tar.gz --directory ${CODEQL_HOME} 
    rm /tmp/codeql-bundle-linux64.tar.gz
}

check_version

install_codeql