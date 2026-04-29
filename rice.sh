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
# 2. ROSÉ PINE COLOR SCHEME — written directly, no download needed
#    Palette: base #191724  surface #1f1d2e  text #e0def4  love #eb6f92
# ══════════════════════════════════════════════════════════════════════════════
log "Writing Rosé Pine color scheme..."

mkdir -p "$HOME/.local/share/color-schemes"
cat > "$HOME/.local/share/color-schemes/RosePine.colors" << 'COLORS'
[ColorEffects:Disabled]
Color=112,110,125
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,110,125
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=39,37,60
BackgroundNormal=31,29,46
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:Complementary]
BackgroundAlternate=39,37,60
BackgroundNormal=25,23,36
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:Header]
BackgroundAlternate=31,29,46
BackgroundNormal=25,23,36
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:Selection]
BackgroundAlternate=235,111,146
BackgroundNormal=235,111,146
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=224,222,244
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=25,23,36
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:Tooltip]
BackgroundAlternate=31,29,46
BackgroundNormal=25,23,36
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:View]
BackgroundAlternate=25,23,36
BackgroundNormal=31,29,46
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[Colors:Window]
BackgroundAlternate=31,29,46
BackgroundNormal=25,23,36
DecorationFocus=235,188,186
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=110,106,134
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=49,116,143
ForegroundVisited=196,167,231

[General]
ColorScheme=RosePine
Name=Rosé Pine
shadeSortColumn=true

[KDE]
contrast=4
COLORS

ok "Rosé Pine color scheme written."

# ── GTK theme ─────────────────────────────────────────────────────────────────
paru -S --needed --noconfirm rose-pine-gtk-theme-full 2>/dev/null || \
  warn "rose-pine-gtk not in AUR — GTK apps fall back to Breeze Dark."

# ══════════════════════════════════════════════════════════════════════════════
# 3. APPLY COLOR SCHEME + PLASMA THEME
# ══════════════════════════════════════════════════════════════════════════════
log "Applying Rosé Pine..."

plasma-apply-colorscheme RosePine 2>/dev/null || \
  kwriteconfig6 --file kdeglobals --group General --key ColorScheme 'RosePine'

plasma-apply-desktoptheme 'breeze-dark' 2>/dev/null || \
  kwriteconfig6 --file plasmarc --group Theme --key name 'breeze-dark'
ok "Plasma theme set to Breeze Dark (neutral, doesn't fight the color scheme)."

# ══════════════════════════════════════════════════════════════════════════════
# 4. KVANTUM — Qt application theming
#    Catppuccin Mocha as Kvantum engine (dark, neutral enough)
#    The color scheme overrides window/app colors — Kvantum just sets the style
# ══════════════════════════════════════════════════════════════════════════════
log "Configuring Kvantum..."

# Write kvantum config directly — kvantummanager --set opens a GUI
mkdir -p "$HOME/.config/Kvantum"
cat > "$HOME/.config/Kvantum/kvantum.kvconfig" << 'KV'
[General]
theme=KvArcDark
KV

# Use a theme that's reliably installed alongside kvantum
# If catppuccin kvantum theme installed successfully, prefer that
if [[ -d "$HOME/.local/share/Kvantum/Catppuccin-Mocha-Mauve" || \
      -d "/usr/share/Kvantum/Catppuccin-Mocha-Mauve" ]]; then
  sed -i 's/^theme=.*/theme=Catppuccin-Mocha-Mauve/' "$HOME/.config/Kvantum/kvantum.kvconfig"
elif [[ -d "/usr/share/Kvantum/KvArcDark" ]]; then
  : # already set above
else
  # Fall back to whatever's available
  AVAILABLE=$(ls /usr/share/Kvantum/ 2>/dev/null | head -1)
  [[ -n "$AVAILABLE" ]] && \
    sed -i "s/^theme=.*/theme=$AVAILABLE/" "$HOME/.config/Kvantum/kvantum.kvconfig"
fi

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
wallpaperplugin=org.kde.image

[Containments][1][Wallpaper][org.kde.image][General]
Image=

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

[Containments][3]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][3][Applets][20]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][3][Applets][20][Configuration][General]
launchers=LAUNCHER_PLACEHOLDER

[Containments][3][Configuration]
PreloadWeight=100
APLRC

# ── Build launcher list by finding actual installed .desktop files ────────────
log "Discovering installed .desktop files for dock..."

_find_desktop() {
  local name="$1"; shift
  local candidates=("$@")
  local search_dirs=(
    "$HOME/.local/share/applications"
    "/usr/share/applications"
    "/usr/local/share/applications"
  )
  for candidate in "${candidates[@]}"; do
    for dir in "${search_dirs[@]}"; do
      [[ -f "$dir/$candidate" ]] && echo "applications:$candidate" && return
    done
  done
}

LAUNCHERS=()
_add() { local r; r=$(_find_desktop "$@"); [[ -n "$r" ]] && LAUNCHERS+=("$r"); }

_add ghostty      com.mitchellh.ghostty.desktop ghostty.desktop
_add vivaldi      vivaldi-stable.desktop vivaldi.desktop
_add librewolf    librewolf.desktop librewolf-bin.desktop
_add signal       signal-desktop.desktop signal.desktop
_add discord      discord.desktop Discord.desktop
_add discordcanary discord-canary.desktop
_add slack        slack-desktop.desktop slack.desktop
_add rocketchat   rocketchat-desktop.desktop rocketchat.desktop org.rocket.RocketChat.desktop
_add vscode       code.desktop visual-studio-code.desktop code-oss.desktop
_add zed          dev.zed.Zed.desktop zed.desktop zed-preview.desktop
_add toolbox      jetbrains-toolbox.desktop
_add 1password    1password.desktop _1password.desktop
_add thunderbird  thunderbird.desktop mozilla-thunderbird.desktop
_add gitbutler    gitbutler-bin.desktop gitbutler.desktop
_add linear       linear.desktop linear-app.desktop
_add spotify      spotify.desktop com.spotify.Client.desktop
_add steam        steam.desktop
_add prism        org.prismlauncher.PrismLauncher.desktop prismlauncher.desktop
_add docker       docker-desktop.desktop
_add lens         openlens.desktop OpenLens.desktop lens.desktop
_add compass      mongodb-compass.desktop
_add dbeaver      dbeaver-ce.desktop dbeaver.desktop DBeaver.desktop
_add redis        redisinsight.desktop redisinsight-bin.desktop RedisInsight.desktop
_add bruno        bruno.desktop
_add obs          com.obsproject.Studio.desktop obs.desktop
_add dolphin      org.kde.dolphin.desktop dolphin.desktop

LAUNCHER_STR=$(IFS=','; echo "${LAUNCHERS[*]}")
log "Found ${#LAUNCHERS[@]} apps for dock"

# Patch the placeholder in appletsrc
sed -i "s|launchers=LAUNCHER_PLACEHOLDER|launchers=$LAUNCHER_STR|" "$APPLETSRC"

# plasmashellrc — top bar thin + bottom dock
python3 - "$SHELLRC" << 'PYEOF'
import os, sys

path = sys.argv[1]
lines = []

if os.path.exists(path):
    with open(path) as f:
        skip = False
        for line in f:
            if '[PlasmaViews][Panel 2]' in line or '[PlasmaViews][Panel 3]' in line:
                skip = True
            elif line.startswith('[') and skip and \
                 '[PlasmaViews][Panel 2]' not in line and \
                 '[PlasmaViews][Panel 3]' not in line:
                skip = False
            if not skip:
                lines.append(line)

# Top bar — thin, full-width, flush
lines.append('\n[PlasmaViews][Panel 2][Defaults]\n')
lines.append('floating=0\n')
lines.append('panelLengthMode=1\n')
lines.append('panelVisibility=0\n')
lines.append('thickness=28\n')

# Bottom dock — icons only, fit content, floating
lines.append('\n[PlasmaViews][Panel 3][Defaults]\n')
lines.append('floating=1\n')
lines.append('panelLengthMode=0\n')   # fit content
lines.append('panelVisibility=0\n')   # always visible
lines.append('thickness=56\n')        # taller for icon dock

with open(path, 'w') as f:
    f.writelines(lines)
PYEOF

ok "Panel config written."

# ══════════════════════════════════════════════════════════════════════════════
# 11. KDE SETTINGS — full power desktop defaults
# ══════════════════════════════════════════════════════════════════════════════
log "Applying KDE settings..."

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

# KRunner — free floating, centered
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

# Window snapping — edges only, NOT corners (corners cause the ghosting)
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderTiling     true
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderCornerRatio 0.0

# Disable all electric border corner actions explicitly
kwriteconfig6 --file kwinrc --group ElectricBorders --key Bottom         None
kwriteconfig6 --file kwinrc --group ElectricBorders --key BottomLeft     None
kwriteconfig6 --file kwinrc --group ElectricBorders --key BottomRight    None
kwriteconfig6 --file kwinrc --group ElectricBorders --key Left           None
kwriteconfig6 --file kwinrc --group ElectricBorders --key Right          None
kwriteconfig6 --file kwinrc --group ElectricBorders --key Top            None
kwriteconfig6 --file kwinrc --group ElectricBorders --key TopLeft        None
kwriteconfig6 --file kwinrc --group ElectricBorders --key TopRight       None

# Accent colour — rose (#eb6f92)
kwriteconfig6 --file kdeglobals --group General --key AccentColor '235,111,146'
kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false

# Task switcher — thumbnail grid (cleaner than default)
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName 'thumbnail_grid'

# Scrolling — natural (like Windows)
kwriteconfig6 --file kcminputrc --group Libinput --key NaturalScroll true

# Click method — modern touchpad behaviour
kwriteconfig6 --file kcminputrc --group Libinput --key TapToClick true
kwriteconfig6 --file kcminputrc --group Libinput --key TwoFingerTap true

# File manager — show hidden files by default
kwriteconfig6 --file dolphinrc --group General --key ShowHiddenFiles false
kwriteconfig6 --file dolphinrc --group General --key ViewMode 1   # icon view

# Clipboard — keep 30 entries
kwriteconfig6 --file klipperrc --group General --key MaxClipItems 30
kwriteconfig6 --file klipperrc --group General --key KeepClipboardContents true

# Notifications — do not disturb during fullscreen (gaming)
kwriteconfig6 --file plasmanotifyrc \
  --group Notifications --key InhibitNotificationsWhenScreensMirrored true

# Power — never sleep, never dim, never lock
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 0

POWER_CFG="$HOME/.config/powermanagementprofilesrc"
mkdir -p "$(dirname "$POWER_CFG")"
cat > "$POWER_CFG" << 'POWER'
[AC][BrightnessControl]
value=100

[AC][DPMSControl]
idleTime=0
lockBeforeTurnOff=0

[AC][DimDisplay]
idleTime=0

[AC][HandleButtonEvents]
lidAction=0
powerButtonAction=1

[AC][SuspendSession]
idleTime=0
suspendThenHibernate=false
suspendType=0

[Battery][BrightnessControl]
value=100

[Battery][DPMSControl]
idleTime=0
lockBeforeTurnOff=0

[Battery][SuspendSession]
idleTime=0
suspendType=0

[LowBattery][SuspendSession]
idleTime=0
suspendType=0
POWER

ok "KDE settings applied."

# ══════════════════════════════════════════════════════════════════════════════
# 12. WALLPAPERS
# ══════════════════════════════════════════════════════════════════════════════
log "Setting up wallpapers..."

WALL_DIR="$HOME/.local/share/wallpapers/rice"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_WALLS="$REPO_DIR/wallpapers"

mkdir -p "$WALL_DIR"

if [[ -d "$REPO_WALLS" ]]; then
  find "$REPO_WALLS" -maxdepth 1 \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -exec cp {} "$WALL_DIR/" \;
  COUNT=$(find "$WALL_DIR" -maxdepth 1 -type f | wc -l)
  ok "$COUNT wallpapers copied to $WALL_DIR"
else
  warn "wallpapers/ not found next to rice.sh"
fi

# Apply wallpaper — try slideshow first, fall back to first image
FIRST_WALL=$(find "$WALL_DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  | sort | head -1)

if [[ -n "$FIRST_WALL" ]]; then
  # Apply immediately via plasma-apply-wallpaperimage
  plasma-apply-wallpaperimage "$FIRST_WALL" 2>/dev/null && \
    ok "Wallpaper applied: $(basename "$FIRST_WALL")" || true

  # Set slideshow via qdbus (works on running session)
  # This tells the desktop containment to switch to slideshow plugin
  qdbus6 org.kde.plasmashell /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript "
      var allDesktops = desktops();
      for (var i = 0; i < allDesktops.length; i++) {
        var d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.slideshow';
        d.currentConfigGroup = ['Wallpaper', 'org.kde.slideshow', 'General'];
        d.writeConfig('SlidePaths', '$WALL_DIR');
        d.writeConfig('SlideInterval', 1800);
        d.writeConfig('Shuffle', true);
      }
    " 2>/dev/null && ok "Slideshow configured (30 min rotation, shuffled)." || \
    warn "Could not set slideshow via qdbus — wallpaper still applied as static."
else
  warn "No wallpapers found in $WALL_DIR — add images and re-run."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 13. GHOSTTY — ensure theme file exists
# ══════════════════════════════════════════════════════════════════════════════
log "Writing Ghostty rose-pine theme..."

mkdir -p "$HOME/.config/ghostty/themes"
cat > "$HOME/.config/ghostty/themes/rose-pine" << 'THEME'
palette = 0=#191724
palette = 1=#eb6f92
palette = 2=#31748f
palette = 3=#f6c177
palette = 4=#9ccfd8
palette = 5=#c4a7e7
palette = 6=#ebbcba
palette = 7=#e0def4
palette = 8=#26233a
palette = 9=#eb6f92
palette = 10=#31748f
palette = 11=#f6c177
palette = 12=#9ccfd8
palette = 13=#c4a7e7
palette = 14=#ebbcba
palette = 15=#e0def4
background = 191724
foreground = e0def4
cursor-color = e0def4
selection-background = 403d52
selection-foreground = e0def4
THEME
ok "Ghostty theme file written."

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