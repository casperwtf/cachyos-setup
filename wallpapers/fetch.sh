#!/usr/bin/env bash
# wallpapers/fetch.sh
# copies bundled wallpapers from the repo into the KDE wallpaper directory
# rice.sh calls this automatically — you don't need to run it manually

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.local/share/wallpapers/rice"

mkdir -p "$DEST"

count=0
for f in "$SCRIPT_DIR"/*.{jpg,jpeg,png,webp}; do
    [[ -f "$f" ]] || continue
    cp "$f" "$DEST/"
    echo "  → $(basename "$f")"
    ((count++))
done

echo ""
echo "  $count wallpaper(s) copied to $DEST"
