#!/usr/bin/env bash
# entry point — clones the repo so scripts have access to bundled wallpapers

set -euo pipefail

REPO="https://github.com/YOUR_USERNAME/cachyos-setup"
DEST="$HOME/cachyos-setup"

if [[ -d "$DEST/.git" ]]; then
    echo "  repo exists at $DEST, pulling latest..."
    git -C "$DEST" pull --ff-only
else
    echo "  cloning $REPO..."
    git clone --depth 1 "$REPO" "$DEST"
fi

cd "$DEST"

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
    1) bash "$DEST/setup.sh"  ;;
    2) bash "$DEST/rice.sh"   ;;
    3) bash "$DEST/setup.sh"; bash "$DEST/rice.sh" ;;
    *) echo "  invalid"; exit 1 ;;
esac
