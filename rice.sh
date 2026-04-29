#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  kde-rice.sh  v2  —  Warm Minimal  ·  Top Bar  ·  GNOME-feel on KDE
#
#  Reference: the screenshots you provided
#    ✦ Thin dark top bar  —  full-width, barely visible
#    ✦ [date] centered  ·  tray right  ·  nothing else
#    ✦ No taskbar  —  window switch via Overview (Meta key)
#    ✦ Warm neutral dark, NOT cold blue
#    ✦ Wallpaper carries all the visual weight
#
#  Color stack → Rosé Pine (warm dusty-dark, rose/gold accents)
#  Palette:
#    Base     #191724   Surface  #1f1d2e   Overlay  #26233a
#    Text     #e0def4   Subtle   #908caa   Muted    #6e6a86
#    Love     #eb6f92   Gold     #f6c177   Rose     #ebbcba
#    Pine     #31748f   Foam     #9ccfd8   Iris     #c4a7e7
#
#  Run AFTER first login inside a KDE Plasma session.
#  Backs up existing panel config automatically.
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

C='\033[0;36m' G='\033[0;32m' Y='\033[1;33m' W='\033[1;37m' R='\033[0;31m' D='\033[0m'
log()  { echo -e "${C}→${D} $*"; }
ok()   { echo -e "${G}✔${D} $*"; }
warn() { echo -e "${Y}⚠${D}  $*"; }
die()  { echo -e "${R}✖${D} $*" >&2; exit 1; }
ask()  { return 0; }   # always yes — runs unattended

[[ $EUID -eq 0 ]]                      && die "Run as normal user."
command -v paru &>/dev/null            || die "paru not found — run main setup script first."
pgrep -x plasmashell &>/dev/null       || die "Not in a KDE session — log in first."
command -v kwriteconfig6 &>/dev/null   || die "kwriteconfig6 not found — KDE tools missing."

echo -e "\n${W}━━━  KDE Rice v2: Warm Minimal  ━━━${D}\n"

# ══════════════════════════════════════════════════════════════════════════════
# 1. PACKAGES
# ══════════════════════════════════════════════════════════════════════════════
log "Installing packages..."

sudo pacman -S --needed --noconfirm \
  kvantum qt5ct qt6ct \
  imagemagick \
  papirus-icon-theme

paru -S --needed --noconfirm \
  klassy \
  kvantum-theme-catppuccin-git \
  papirus-folders-catppuccin-git \
  catppuccin-cursors-mocha-dark-git 2>/dev/null || true

ok "Base packages ready."

# ══════════════════════════════════════════════════════════════════════════════
# 2. ROSÉ PINE COLOR SCHEME
#    Warm dark palette — base #191724, accents rose/gold/love
# ══════════════════════════════════════════════════════════════════════════════
log "Installing Rosé Pine color scheme..."

# Try AUR package first, fall back to manual install
if ! paru -S --needed --noconfirm kde-theme-rosepine-git 2>/dev/null; then
  # Manual install from official repo
  TMP=$(mktemp -d)
  log "Downloading Rosé Pine KDE theme..."
  curl -fsSL https://api.github.com/repos/rose-pine/kde/tarball/main \
    | tar -xz -C "$TMP" --strip-components=1

  mkdir -p "$HOME/.local/share/color-schemes"
  find "$TMP" -name "*.colors" -exec cp {} "$HOME/.local/share/color-schemes/" \;

  mkdir -p "$HOME/.local/share/aurorae/themes"
  find "$TMP" -maxdepth 3 -type d \( -iname "*rose*pine*" -o -iname "*Rosé*" \) \
    -exec cp -r {} "$HOME/.local/share/aurorae/themes/" \; 2>/dev/null || true

  rm -rf "$TMP"
fi
ok "Rosé Pine installed."

# ── GTK theme — Rosé Pine for Firefox, Thunderbird, etc. ─────────────────────
paru -S --needed --noconfirm rose-pine-gtk-theme-full 2>/dev/null || \
  warn "rose-pine-gtk not found in AUR — GTK apps will use Breeze Dark fallback."

# ══════════════════════════════════════════════════════════════════════════════
# 3. APPLY COLOR SCHEME + PLASMA THEME
# ══════════════════════════════════════════════════════════════════════════════
log "Applying Rosé Pine Main (dark warm)..."

# Try plasma-apply-colorscheme (Plasma 6)
SCHEME_NAME=""
for name in "RosePineMain" "RosePine" "rose-pine" "RosePineMoon"; do
  if plasma-apply-colorscheme "$name" 2>/dev/null; then
    SCHEME_NAME="$name"; break
  fi
done

if [[ -z "$SCHEME_NAME" ]]; then
  warn "Could not auto-apply color scheme — set manually: System Settings → Colors"
  warn "Look for 'Rose Pine' or 'Rosé Pine' in the list."
fi

# Plasma shell theme — closest built-in to a neutral dark floating panel
# "Breeze Dark" plasma theme has a neutral dark panel that suits this aesthetic
plasma-apply-desktoptheme 'Breeze Dark' 2>/dev/null || \
  kwriteconfig6 --file plasmarc --group Theme --key name 'breeze-dark'
ok "Plasma theme set to Breeze Dark (neutral, doesn't fight the color scheme)."

# ══════════════════════════════════════════════════════════════════════════════
# 4. KVANTUM — Qt application theming
#    Catppuccin Mocha as Kvantum engine (dark, neutral enough)
#    The color scheme overrides window/app colors — Kvantum just sets the style
# ══════════════════════════════════════════════════════════════════════════════
log "Configuring Kvantum..."

kvantummanager --set Catppuccin-Mocha-Mauve 2>/dev/null || \
  warn "Set Kvantum theme manually: run kvantummanager → select Catppuccin-Mocha or similar"

kwriteconfig6 --file qt5ct/qt5ct.conf --group Appearance --key style kvantum
kwriteconfig6 --file qt6ct/qt6ct.conf --group Appearance --key style kvantum
ok "Kvantum configured."

# ══════════════════════════════════════════════════════════════════════════════
# 5. ICONS + CURSOR
# ══════════════════════════════════════════════════════════════════════════════
log "Setting icons and cursor..."

# Papirus with Rose-tinted folder colors (closest to warm)
papirus-folders -C pink --theme Papirus-Dark 2>/dev/null || true

kwriteconfig6 --file kdeglobals --group Icons --key Theme 'Papirus-Dark'
kwriteconfig6 --file kcminputrc  --group Mouse --key cursorTheme 'catppuccin-mocha-dark-cursors'
kwriteconfig6 --file kdeglobals  --group Icons --key cursorTheme 'catppuccin-mocha-dark-cursors'

mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Inherits=catppuccin-mocha-dark-cursors
EOF
echo "Xcursor.theme: catppuccin-mocha-dark-cursors" >> "$HOME/.Xresources"
ok "Icons and cursor set."

# ══════════════════════════════════════════════════════════════════════════════
# 6. WINDOW DECORATIONS — minimal, thin, Rosé Pine or Klassy
# ══════════════════════════════════════════════════════════════════════════════
log "Configuring window decorations..."

kwriteconfig6 --file kwinrc \
  --group org.kde.kdecoration2 --key library 'org.kde.klassy'

# Klassy: thin titlebar, small buttons, tight margins
# This is what makes window chrome nearly invisible
kwriteconfig6 --file klassyrc --group Windeco --key cornerRadius     '6'
kwriteconfig6 --file klassyrc --group Windeco --key buttonSize       'Small'
kwriteconfig6 --file klassyrc --group Windeco --key titlebarTopMargin    '2'
kwriteconfig6 --file klassyrc --group Windeco --key titlebarBottomMargin '2'
kwriteconfig6 --file klassyrc --group Windeco --key titlebarSideMargin   '6'
kwriteconfig6 --file klassyrc --group Windeco --key drawBackgroundGradient false

# Borderless when maximized — full bleed, like the file manager in screenshot 4
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
ok "Klassy decorations configured."

# ══════════════════════════════════════════════════════════════════════════════
# 7. KWIN — effects, animations, Overview (the GNOME Activities equivalent)
# ══════════════════════════════════════════════════════════════════════════════
log "Configuring KWin effects and Overview..."

# Compositor
kwriteconfig6 --file kwinrc --group Compositing --key Backend       OpenGL
kwriteconfig6 --file kwinrc --group Compositing --key GLTextureFilter 2
kwriteconfig6 --file kwinrc --group Compositing --key LatencyControl  0
kwriteconfig6 --file kwinrc --group Compositing --key WindowCornerRadius 7

# Blur — panel, menus, windows with blur
kwriteconfig6 --file kwinrc --group Plugins       --key blurEnabled   true
kwriteconfig6 --file kwinrc --group Effect-blur   --key BlurStrength  7
kwriteconfig6 --file kwinrc --group Effect-blur   --key NoiseStrength 0    # no noise — cleaner

# Overview effect (GNOME Activities equivalent — shows all windows + workspaces)
kwriteconfig6 --file kwinrc --group Plugins --key overviewEnabled   true
kwriteconfig6 --file kwinrc --group Plugins --key diminishEnabled   false
kwriteconfig6 --file kwinrc --group Plugins --key desktopgridEnabled false  # use Overview instead
kwriteconfig6 --file kwinrc --group Plugins --key zoomEnabled       false

# Animation speed — 3 = snappy default
kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 4

# Disable plugins that add visual noise
kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key jellyfishEnabled   false
kwriteconfig6 --file kwinrc --group Plugins --key glideEnabled       false

# ── Meta key → opens Overview (like GNOME's Super key) ──────────────────────
# This makes pressing Meta alone show all windows, exactly like GNOME Activities
kwriteconfig6 --file kwinrc \
  --group ModifierOnlyShortcuts \
  --key Meta 'org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview'

# Also set Meta+Tab as Overview shortcut (fallback)
kwriteconfig6 --file kglobalshortcutsrc \
  --group kwin --key 'Overview' 'Meta+Tab,Meta+Tab,Toggle Overview'

# Window tiling — snap to halves like Windows
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderTiling      true
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderCornerRatio  0.25
ok "KWin effects + Overview configured."

# ══════════════════════════════════════════════════════════════════════════════
# 8. FONT RENDERING
# ══════════════════════════════════════════════════════════════════════════════
log "Configuring fonts..."

kwriteconfig6 --file kdeglobals \
  --group General --key font 'Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
kwriteconfig6 --file kdeglobals \
  --group General --key fixed 'JetBrainsMono Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
kwriteconfig6 --file kcmfonts --group General --key antiAliasing  1
kwriteconfig6 --file kcmfonts --group General --key subPixelType  rgb
kwriteconfig6 --file kcmfonts --group General --key hintingStyle  slight

mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'FONTCONF'
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="rgba"       mode="assign"><const>rgb</const></edit>
    <edit name="hinting"    mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle"  mode="assign"><const>hintslight</const></edit>
    <edit name="antialias"  mode="assign"><bool>true</bool></edit>
    <edit name="lcdfilter"  mode="assign"><const>lcddefault</const></edit>
  </match>
  <alias><family>monospace</family>
    <prefer><family>JetBrainsMono Nerd Font</family></prefer></alias>
  <alias><family>sans-serif</family>
    <prefer><family>Noto Sans</family></prefer></alias>
</fontconfig>
FONTCONF
ok "Fonts configured."

# ══════════════════════════════════════════════════════════════════════════════
# 9. GTK CONFIG
# ══════════════════════════════════════════════════════════════════════════════
log "Applying GTK Rosé Pine theme..."

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

cat > "$HOME/.config/gtk-3.0/settings.ini" << 'GTK3'
[Settings]
gtk-theme-name                  = rose-pine
gtk-icon-theme-name             = Papirus-Dark
gtk-cursor-theme-name           = catppuccin-mocha-dark-cursors
gtk-font-name                   = Noto Sans 10
gtk-application-prefer-dark-theme = 1
gtk-button-images               = 0
gtk-menu-images                 = 0
GTK3

cat > "$HOME/.config/gtk-4.0/settings.ini" << 'GTK4'
[Settings]
gtk-theme-name                  = rose-pine
gtk-icon-theme-name             = Papirus-Dark
gtk-cursor-theme-name           = catppuccin-mocha-dark-cursors
gtk-font-name                   = Noto Sans 10
gtk-application-prefer-dark-theme = 1
GTK4

# GTK4 CSS symlink for Qt/KDE apps that use libadwaita
ROSE_PINE_GTK="/usr/share/themes/rose-pine/gtk-4.0"
if [[ -d "$ROSE_PINE_GTK" ]]; then
  ln -sfn "$ROSE_PINE_GTK/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
  ln -sfn "$ROSE_PINE_GTK/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
  ok "GTK4 CSS linked."
fi
ok "GTK configured."

# ══════════════════════════════════════════════════════════════════════════════
# 10. PANEL — thin dark top bar
#     Matches the screenshots exactly:
#       • Full-width, attached top edge  (NOT a bottom pill)
#       • 28px tall — barely visible
#       • [App Menu]  ──────  [Date · Time]  ──────  [System Tray]
#       • No task manager, no window list
#       • Transparent enough to feel non-existent
# ══════════════════════════════════════════════════════════════════════════════
log "Writing panel config (thin top bar, no taskbar)..."

APPLETSRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
SHELLRC="$HOME/.config/plasmashellrc"

# Back up
[[ -f "$APPLETSRC" ]] && cp "$APPLETSRC" "${APPLETSRC}.bak.$(date +%s)"
[[ -f "$SHELLRC"   ]] && cp "$SHELLRC"   "${SHELLRC}.bak.$(date +%s)"

# Preserve activity ID from existing desktop containment
ACTIVITY_ID=$(python3 - "$APPLETSRC" 2>/dev/null << 'PY'
import configparser, sys, os
if not os.path.exists(sys.argv[1]): print(''); exit()
cfg = configparser.RawConfigParser()
cfg.read(sys.argv[1])
for s in cfg.sections():
    if cfg.has_option(s,'plugin') and cfg.get(s,'plugin')=='org.kde.desktopcontainment':
        print(cfg.get(s,'activityId',fallback='')); exit()
PY
)
ACTIVITY_ID="${ACTIVITY_ID:-00000000-0000-0000-0000-000000000000}"

# Write appletsrc
# Containment [1] = desktop (blank)
# Containment [2] = panel (top bar)
# Applets [10-15]
cat > "$APPLETSRC" << APLRC
[ActionPlugins][0]
RightButton;NoModifier=org.kde.contextmenu

[ActionPlugins][0][RightButton;NoModifier]
_add panel=true
_context=true
_lock_screen=true
_logout=true
_run_command=true
_sep1=true
_sep2=true
_sep3=true
_wallpaper=true
add widgets=true
configure=true
configure shortcuts=false
lock widgets=true
manage activities=true

[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu

[Containments][1]
activityId=${ACTIVITY_ID}
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.slideshow

[Containments][1][Wallpaper][org.kde.slideshow][General]
SlidePaths=$HOME/.local/share/wallpapers/rice
SlideInterval=1800
FillMode=2
Shuffle=true

[Containments][2]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=2
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][2][Applets][10]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][2][Applets][10][Configuration][Shortcuts]
global=Meta+F1

[Containments][2][Applets][10][Configuration][General]
favoritesPortedToKAstats=true
showRecentDocs=false
showRecentApps=false
systemFavorites=shutdown\\,reboot\\,logout

[Containments][2][Applets][11]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][2][Applets][12]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][2][Applets][12][Configuration][Appearance]
showDate=true
showSeconds=Never
use24hFormat=2
dateFormat=isoDate
showWeekNumbers=false
fontStyleName=Regular

[Containments][2][Applets][13]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][2][Applets][14]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][2][Applets][14][Configuration][General]
shownItems=org.kde.plasma.networkmanagement,org.kde.plasma.volume
extraItems=org.kde.plasma.bluetooth,org.kde.plasma.battery

[Containments][2][Configuration]
PreloadWeight=100
APLRC

# plasmashellrc — thin, top, not floating (no pill gap needed here)
# Full-width bar like GNOME top panel
python3 - "$SHELLRC" << 'PYEOF'
import os, sys

path = sys.argv[1]
lines = []

if os.path.exists(path):
    with open(path) as f:
        skip = False
        for line in f:
            if '[PlasmaViews][Panel 2]' in line:
                skip = True
            elif line.startswith('[') and skip and '[PlasmaViews][Panel 2]' not in line:
                skip = False
            if not skip:
                lines.append(line)

lines.append('\n[PlasmaViews][Panel 2][Defaults]\n')
lines.append('floating=0\n')          # attached — full-width flush top bar
lines.append('panelLengthMode=1\n')   # 1 = fill width
lines.append('panelVisibility=0\n')   # always visible
lines.append('thickness=28\n')        # thin — 28px matches the screenshots

with open(path, 'w') as f:
    f.writelines(lines)
PYEOF

ok "Panel config written."

# ══════════════════════════════════════════════════════════════════════════════
# 11. MISC KDE SETTINGS
# ══════════════════════════════════════════════════════════════════════════════
log "Applying KDE behaviour settings..."

# Double-click (Windows muscle memory)
kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false

# No startup splash
kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
kwriteconfig6 --file ksplashrc --group KSplash --key Theme  none

# No bouncing cursor on app launch
kwriteconfig6 --file klaunchrc --group BusyCursorSettings --key Bouncing false
kwriteconfig6 --file klaunchrc --group FeedbackStyle       --key BusyCursor false

# Disable Baloo indexer
balooctl6 disable 2>/dev/null || balooctl disable 2>/dev/null || true
kwriteconfig6 --file baloofilerc \
  --group 'Basic Settings' --key Indexing-Enabled false

# KRunner: free-floating, centered (like GNOME's search in overview)
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

# Window snapping
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderTiling     true
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderCornerRatio 0.25

# Accent color — pull from wallpaper (dusty rose to match aesthetic)
# Set to a warm rose color matching the Rosé Pine Love color #eb6f92
kwriteconfig6 --file kdeglobals \
  --group General --key AccentColor '235,111,146'    # #eb6f92 — warm rose
kwriteconfig6 --file kdeglobals \
  --group General --key accentColorFromWallpaper true # or let KDE pull from wallpaper

ok "KDE settings applied."

# ══════════════════════════════════════════════════════════════════════════════
# 12. WALLPAPERS — copy from repo, configure slideshow (30 min rotation)
# ══════════════════════════════════════════════════════════════════════════════
log "Setting up wallpaper rotation..."

WALL_DIR="$HOME/.local/share/wallpapers/rice"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_WALLS="$REPO_DIR/wallpapers"

mkdir -p "$WALL_DIR"

if [[ -d "$REPO_WALLS" ]]; then
  cp "$REPO_WALLS"/*.{jpg,jpeg,png,webp} "$WALL_DIR/" 2>/dev/null || true
  COUNT=$(ls "$WALL_DIR" | wc -l)
  ok "$COUNT wallpapers copied to $WALL_DIR"
else
  warn "wallpapers/ dir not found next to rice.sh — expected repo layout."
  warn "make sure you cloned the repo and are running from inside it."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 13. GHOSTTY — update theme to Rosé Pine
# ══════════════════════════════════════════════════════════════════════════════
log "Updating Ghostty theme to Rosé Pine..."

GHOSTTY_CFG="$HOME/.config/ghostty/config"
if [[ -f "$GHOSTTY_CFG" ]]; then
  sed -i 's/^theme =.*/theme = rose-pine/' "$GHOSTTY_CFG" && \
    ok "Ghostty theme → rose-pine" || \
    warn "Could not update Ghostty config — set 'theme = rose-pine' manually."
else
  warn "Ghostty config not found — run setup.sh first."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 14. RELOAD
# ══════════════════════════════════════════════════════════════════════════════
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

log "Restarting plasmashell..."
kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null || true
sleep 1
nohup plasmashell --replace &>/dev/null &
disown
sleep 3
ok "plasmashell restarted."

# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  Done.${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
echo -e "  ${W}What you now have:${D}"
echo -e "  ${C}Panel${D}       thin dark top bar, full-width, 28px"
echo -e "  ${C}Layout${D}      [⊞] ─────── [Aug 4  13:52] ─────── [tray]"
echo -e "  ${C}Colors${D}      Rosé Pine (warm dark, rose accents)"
echo -e "  ${C}Windows${D}     Klassy, thin titlebar, 7px radius"
echo -e "  ${C}Overview${D}    press Meta → all windows + workspaces"
echo -e "  ${C}Tiling${D}      drag window to screen edge to snap"
echo -e ""
echo -e "  ${C}Wallpaper${D}   slideshow rotating from ~/.local/share/wallpapers/rice/"
echo -e ""
echo -e "  ${Y}Color scheme${D} may need manual selection if auto-apply missed:"
echo -e "             System Settings → Colors → look for 'Rosé Pine'"
echo -e ""
echo -e "  ${Y}Panel width${D} is full-width (not pill) to match the screenshots."
echo -e "  If you still want a centered pill: right-click panel → Edit Panel"
echo -e "  → Width → Fit Content, then drag to center."
echo -e ""