#! /usr/bin/env bash
set -e

DOWNLOAD_BASE='tofu_%s_linux_amd64.tar.gz'

if ! [[ "${PATH}" =~ .local/bin ]]; then
    echo "ERROR: ~/.local/bin not present in PATH, installation aborted."
    exit 1
fi

echo "INFO: Fetching latest release information..."
TAG=$(curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    'https://api.github.com/repos/opentofu/opentofu/releases?per_page=1&page=1' | jq -r '.[0].name')

DOWNLOAD_FILE=$(printf "${DOWNLOAD_BASE}" "${TAG//v}")

echo "INFO: Downloading ${DOWNLOAD_FILE}..."
curl -L -o /tmp/opentofu.tar.gz https://github.com/opentofu/opentofu/releases/download/${TAG}/${DOWNLOAD_FILE}

echo "INFO: Installing..."
tar -C ~/.local/bin -xf /tmp/opentofu.tar.gz tofu

echo "INFO: Cleaning up..."
rm -f /tmp/opentofu.tar.gz

echo "INFO: Done."
