#!/usr/bin/env bash
# run after downloading the repo:
#   mkdir -p ~/cachyos-setup && curl -fsSL https://api.github.com/repos/casperwtf/cachyos-setup/tarball/main | tar -xz -C ~/cachyos-setup --strip-components=1 && bash ~/cachyos-setup/install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARBALL="https://api.github.com/repos/casperwtf/cachyos-setup/tarball/main"

if [[ "${1:-}" == "--update" ]]; then
    echo "  pulling latest..."
    curl -fsSL "$TARBALL" | tar -xz -C "$REPO_DIR" --strip-components=1
    echo "  updated."
    echo ""
fi

bash "$REPO_DIR/setup.sh"
bash "$REPO_DIR/rice.sh"