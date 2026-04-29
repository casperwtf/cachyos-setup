#!/usr/bin/env bash
# run after downloading the repo:
#   mkdir -p ~/cachyos-setup && curl -fsSL https://api.github.com/repos/casperwtf/cachyos-setup/tarball/main | tar -xz -C ~/cachyos-setup --strip-components=1 && bash ~/cachyos-setup/install.sh
#
# to pull the latest version before running:
#   bash ~/cachyos-setup/install.sh --update

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARBALL="https://api.github.com/repos/casperwtf/cachyos-setup/tarball/main"

if [[ "${1:-}" == "--update" ]]; then
    echo "  pulling latest..."
    curl -fsSL "$TARBALL" | tar -xz -C "$REPO_DIR" --strip-components=1
    echo "  updated."
    echo ""
fi

echo ""
echo "  what do you want to run?"
echo ""
echo "  1) setup.sh   packages, JDKs, browsers, IDEs, gaming, devops"
echo "  2) rice.sh    KDE theme + wallpapers  (needs an active KDE session)"
echo "  3) both"
echo ""
printf "  [1/2/3]: "
read -r choice

case "$choice" in
    1) bash "$REPO_DIR/setup.sh"  ;;
    2) bash "$REPO_DIR/rice.sh"   ;;
    3) bash "$REPO_DIR/setup.sh"; bash "$REPO_DIR/rice.sh" ;;
    *) echo "  invalid"; exit 1 ;;
esac