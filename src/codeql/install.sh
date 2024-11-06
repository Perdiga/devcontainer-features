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


get_valid_releases() {
    echo "Getting valid CodeQL releases from GitHub API"

    page=1
    releases=""

    while true; do
        # Fetch a page of releases
        response=$(curl -s "https://api.github.com/repos/github/codeql-action/releases?per_page=100&page=$page")
        echo "debug: response: $response"

        # Check if there are no more releases
        if [ "$(echo "$response" | jq '. | length')" -eq 0 ]; then
            break
        fi

        # Extract valid releases and add to the list
        valid_releases=$(echo "$response" | jq -r '.[].tag_name' | grep '^codeql-bundle-v')
        releases="${releases}${valid_releases}\n"

        # Move to the next page
        page=$((page + 1))
    done

    # Print all valid releases, one per line
    echo "Valid CodeQL releases:"
    printf "%s" "$releases"

    # Set the codeql version to the latest if it is not provided
    if [ "$CODEQL_VERSION" = "latest" ]; then
        # Get the latest release
        CODEQL_LATEST=$(echo "$releases" | head -n 1)
        CODEQL_VERSION=${CODEQL_LATEST#codeql-bundle-v}  # Remove the prefix 'codeql-bundle-v'
        echo "Setting the CodeQL version to the latest: $CODEQL_VERSION"
    fi
}

check_version() {
    echo "Checking if the provided version is valid"

    # Check if the current version is in the list of valid releases
    if get_valid_releases | grep -qx "codeql-bundle-v$CODEQL_VERSION"; then
        echo "The provided CodeQL version ($CODEQL_VERSION) is valid."
    else
        echo "The provided CodeQL version ($CODEQL_VERSION) is not valid."
        exit 1
    fi
}

install_packages() {
    echo "Installing required packages"

    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        jq

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

install_packages

check_version

install_codeql