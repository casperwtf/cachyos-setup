#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  rice.sh — KDE theming for CachyOS
#  idempotent: safe to re-run
#  run from inside a KDE Plasma session
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'
log()  { echo -e "${C}→${D} $*"; }
ok()   { echo -e "${G}✔${D} $*"; }
warn() { echo -e "${Y}⚠${D}  $*"; }
h()    { echo -e "\n${W}━━━  $*  ━━━${D}"; }
kw6()  { kwriteconfig6 "$@"; }

[[ $EUID -eq 0 ]]                    && { echo "run as normal user"; exit 1; }
pgrep -x plasmashell &>/dev/null     || { echo "plasmashell not running — log into KDE first"; exit 1; }
command -v kwriteconfig6 &>/dev/null || { echo "kwriteconfig6 not found"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\n${W}  KDE rice — Rosé Pine · warm minimal${D}\n"

# ══════════════════════════════════════════════════════════════════════════════
h "packages"
# ══════════════════════════════════════════════════════════════════════════════

sudo pacman -S --needed --noconfirm kvantum qt5ct qt6ct imagemagick papirus-icon-theme
paru -S --needed --noconfirm klassy-bin catppuccin-kde-git bibata-cursor-theme \
  kvantum-theme-catppuccin-git 2>/dev/null || true
ok "packages ready"

# ══════════════════════════════════════════════════════════════════════════════
h "Rosé Pine color scheme"
# ══════════════════════════════════════════════════════════════════════════════

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

plasma-apply-colorscheme RosePine 2>/dev/null \
  || kw6 --file kdeglobals --group General --key ColorScheme RosePine
ok "color scheme applied"

# ══════════════════════════════════════════════════════════════════════════════
h "Plasma shell theme"
# ══════════════════════════════════════════════════════════════════════════════

plasma-apply-desktoptheme breeze-dark 2>/dev/null \
  || kw6 --file plasmarc --group Theme --key name breeze-dark
ok "plasma theme: breeze-dark"

# ══════════════════════════════════════════════════════════════════════════════
h "Kvantum"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/Kvantum"
# pick best available theme
KVTHEME="KvArcDark"
for t in Catppuccin-Mocha-Mauve catppuccin-mocha; do
  [[ -d "$HOME/.local/share/Kvantum/$t" || -d "/usr/share/Kvantum/$t" ]] \
    && KVTHEME="$t" && break
done
cat > "$HOME/.config/Kvantum/kvantum.kvconfig" << EOF
[General]
theme=$KVTHEME
EOF
kw6 --file qt5ct/qt5ct.conf --group Appearance --key style kvantum
kw6 --file qt6ct/qt6ct.conf --group Appearance --key style kvantum
ok "Kvantum: $KVTHEME"

# ══════════════════════════════════════════════════════════════════════════════
h "icons · cursor"
# ══════════════════════════════════════════════════════════════════════════════

papirus-folders -C pink --theme Papirus-Dark 2>/dev/null || true
kw6 --file kdeglobals --group Icons --key Theme Papirus-Dark
kw6 --file kcminputrc  --group Mouse --key cursorTheme bibata-modern-classic
kw6 --file kdeglobals  --group Icons --key cursorTheme bibata-modern-classic
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Inherits=bibata-modern-classic
EOF
ok "icons: Papirus-Dark · cursor: bibata-modern-classic"

# ══════════════════════════════════════════════════════════════════════════════
h "window decorations — Klassy"
# ══════════════════════════════════════════════════════════════════════════════

kw6 --file kwinrc --group org.kde.kdecoration2 --key library   org.kde.klassy
kw6 --file kwinrc --group org.kde.kdecoration2 --key theme     ''
kw6 --file kwinrc --group Windows              --key BorderlessMaximizedWindows true
kw6 --file klassyrc --group Windeco --key cornerRadius          6
kw6 --file klassyrc --group Windeco --key buttonSize            Small
kw6 --file klassyrc --group Windeco --key titlebarTopMargin     2
kw6 --file klassyrc --group Windeco --key titlebarBottomMargin  2
kw6 --file klassyrc --group Windeco --key titlebarSideMargin    6
ok "Klassy decorations configured"

# ══════════════════════════════════════════════════════════════════════════════
h "KWin effects"
# ══════════════════════════════════════════════════════════════════════════════

kw6 --file kwinrc --group Compositing --key Backend             OpenGL
kw6 --file kwinrc --group Compositing --key GLTextureFilter     2
kw6 --file kwinrc --group Compositing --key LatencyControl      0
kw6 --file kwinrc --group Compositing --key AnimationSpeed      4
kw6 --file kwinrc --group Compositing --key WindowCornerRadius  7
kw6 --file kwinrc --group Plugins     --key blurEnabled         true
kw6 --file kwinrc --group Effect-blur --key BlurStrength        7
kw6 --file kwinrc --group Effect-blur --key NoiseStrength       0
kw6 --file kwinrc --group Plugins     --key overviewEnabled     true
kw6 --file kwinrc --group Plugins     --key desktopgridEnabled  false
kw6 --file kwinrc --group Plugins     --key zoomEnabled         false
kw6 --file kwinrc --group Plugins     --key wobblywindowsEnabled false
# Meta key → Overview (like GNOME Super)
kw6 --file kwinrc --group ModifierOnlyShortcuts --key Meta \
  'org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview'
# Electric borders — edges only, corners disabled (no accidental triggers on laptop)
kw6 --file kwinrc --group Windows        --key ElectricBorderTiling      true
kw6 --file kwinrc --group Windows        --key ElectricBorderCornerRatio 0.0
kw6 --file kwinrc --group ElectricBorders --key TopLeft     None
kw6 --file kwinrc --group ElectricBorders --key TopRight    None
kw6 --file kwinrc --group ElectricBorders --key BottomLeft  None
kw6 --file kwinrc --group ElectricBorders --key BottomRight None
kw6 --file kwinrc --group ElectricBorders --key Top         None
kw6 --file kwinrc --group ElectricBorders --key Bottom      None
kw6 --file kwinrc --group ElectricBorders --key Left        None
kw6 --file kwinrc --group ElectricBorders --key Right       None
ok "KWin effects configured"

# ══════════════════════════════════════════════════════════════════════════════
h "fonts"
# ══════════════════════════════════════════════════════════════════════════════

kw6 --file kdeglobals --group General --key font        'Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
kw6 --file kdeglobals --group General --key fixed       'JetBrainsMono Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
kw6 --file kcmfonts   --group General --key antiAliasing  1
kw6 --file kcmfonts   --group General --key subPixelType  rgb
kw6 --file kcmfonts   --group General --key hintingStyle  slight
ok "font rendering configured"

# ══════════════════════════════════════════════════════════════════════════════
h "GTK"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'GTK3'
[Settings]
gtk-theme-name                  = Breeze-Dark
gtk-icon-theme-name             = Papirus-Dark
gtk-cursor-theme-name           = bibata-modern-classic
gtk-font-name                   = Noto Sans 10
gtk-application-prefer-dark-theme = 1
GTK3
cat > "$HOME/.config/gtk-4.0/settings.ini" << 'GTK4'
[Settings]
gtk-theme-name                  = Breeze-Dark
gtk-icon-theme-name             = Papirus-Dark
gtk-cursor-theme-name           = bibata-modern-classic
gtk-font-name                   = Noto Sans 10
gtk-application-prefer-dark-theme = 1
GTK4
ok "GTK configured"

# ══════════════════════════════════════════════════════════════════════════════
h "KDE settings"
# ══════════════════════════════════════════════════════════════════════════════

# general behaviour
kw6 --file kdeglobals --group KDE     --key SingleClick                false
kw6 --file kdeglobals --group General --key AccentColor                '235,111,146'
kw6 --file kdeglobals --group General --key accentColorFromWallpaper   false

# splash / startup
kw6 --file ksplashrc  --group KSplash --key Engine  none
kw6 --file ksplashrc  --group KSplash --key Theme   none
kw6 --file klaunchrc  --group BusyCursorSettings --key Bouncing  false
kw6 --file klaunchrc  --group FeedbackStyle      --key BusyCursor false

# screen lock — disabled (always on charger, always present)
kw6 --file kscreenlockerrc --group Daemon --key Autolock false
kw6 --file kscreenlockerrc --group Daemon --key Timeout  0

# baloo — disable file indexer
balooctl6 disable 2>/dev/null || balooctl disable 2>/dev/null || true
kw6 --file baloofilerc --group 'Basic Settings' --key Indexing-Enabled false

# task switcher
kw6 --file kwinrc --group TabBox --key LayoutName thumbnail_grid

# KRunner — free floating
kw6 --file krunnerrc --group General --key FreeFloating true

# notifications — no interruptions during fullscreen (gaming/coding)
kw6 --file plasmanotifyrc --group Notifications --key InhibitNotificationsWhenScreensMirrored true

# clipboard history
kw6 --file klipperrc --group General --key MaxClipItems       30
kw6 --file klipperrc --group General --key KeepClipboardContents true

# input — laptop-friendly defaults
kw6 --file kcminputrc --group Libinput --key NaturalScroll  true
kw6 --file kcminputrc --group Libinput --key TapToClick     true
kw6 --file kcminputrc --group Libinput --key TwoFingerTap   true
kw6 --file kcminputrc --group Libinput --key ScrollMethod   2

# power — never sleep, never dim
cat > "$HOME/.config/powermanagementprofilesrc" << 'POWER'
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

ok "KDE settings applied"

# ══════════════════════════════════════════════════════════════════════════════
h "panels — top bar + bottom dock"
# ══════════════════════════════════════════════════════════════════════════════

# suspend exit-on-error for the panel section — config failures shouldn't
# abort the whole rice; panels can be fixed manually
set +e

APPLETSRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
SHELLRC="$HOME/.config/plasmashellrc"

[[ -f "$APPLETSRC" ]] && cp "$APPLETSRC" "${APPLETSRC}.bak"
[[ -f "$SHELLRC"   ]] && cp "$SHELLRC"   "${SHELLRC}.bak"

# preserve current desktop activity id
ACTIVITY_ID=$(python3 -c "
import configparser, sys, os
path = '${APPLETSRC}'
if not os.path.exists(path): print(''); exit()
cfg = configparser.RawConfigParser()
cfg.read(path)
for s in cfg.sections():
    if cfg.has_option(s,'plugin') and cfg.get(s,'plugin')=='org.kde.desktopcontainment':
        print(cfg.get(s,'activityId',fallback='')); exit()
" 2>/dev/null || echo '')
ACTIVITY_ID="${ACTIVITY_ID:-00000000-0000-0000-0000-000000000000}"

# ── discover installed .desktop files for dock ────────────────────────────────
_find_desktop() {
  for c in "$@"; do
    for d in "$HOME/.local/share/applications" /usr/share/applications /usr/local/share/applications; do
      [[ -f "$d/$c" ]] && echo "applications:$c" && return
    done
  done
}

LAUNCHERS=()
_add() { local r; r=$(_find_desktop "$@") && [[ -n "$r" ]] && LAUNCHERS+=("$r") || true; }

_add com.mitchellh.ghostty.desktop ghostty.desktop
_add vivaldi-stable.desktop vivaldi.desktop
_add librewolf.desktop librewolf-bin.desktop
_add signal-desktop.desktop signal.desktop
_add discord.desktop Discord.desktop
_add discord-canary.desktop
_add slack-desktop.desktop slack.desktop
_add rocketchat-desktop.desktop rocketchat.desktop
_add code.desktop visual-studio-code.desktop
_add dev.zed.Zed.desktop zed.desktop
_add jetbrains-toolbox.desktop
_add 1password.desktop _1password.desktop
_add thunderbird.desktop mozilla-thunderbird.desktop
_add gitbutler-bin.desktop gitbutler.desktop
_add linear.desktop linear-app.desktop
_add spotify.desktop com.spotify.Client.desktop
_add steam.desktop
_add org.prismlauncher.PrismLauncher.desktop prismlauncher.desktop
_add docker-desktop.desktop
_add openlens.desktop OpenLens.desktop
_add mongodb-compass.desktop
_add dbeaver-ce.desktop dbeaver.desktop DBeaver.desktop
_add redisinsight.desktop RedisInsight.desktop
_add bruno.desktop
_add com.obsproject.Studio.desktop obs.desktop
_add org.kde.dolphin.desktop dolphin.desktop

# safe join — handles empty array without nounset error
LAUNCHER_STR=""
if [[ ${#LAUNCHERS[@]} -gt 0 ]]; then
  LAUNCHER_STR=$(printf '%s,' "${LAUNCHERS[@]}")
  LAUNCHER_STR="${LAUNCHER_STR%,}"  # strip trailing comma
fi

log "dock: ${#LAUNCHERS[@]} apps found"

# ── appletsrc ─────────────────────────────────────────────────────────────────
# location enum in Plasma 6 config files:
#   0=Floating  1=Desktop  2=FullScreen
#   3=TopEdge   4=BottomEdge  5=LeftEdge  6=RightEdge
cat > "$APPLETSRC" << APLRC
[ActionPlugins][0]
RightButton;NoModifier=org.kde.contextmenu

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

[Containments][2]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
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
fontStyleName=Regular

[Containments][2][Applets][13]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][2][Applets][14]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][2][Applets][14][Configuration][General]
shownItems=org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.battery
extraItems=org.kde.plasma.bluetooth

[Containments][2][Configuration]
PreloadWeight=100

[Containments][3]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][3][Applets][20]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][3][Applets][20][Configuration][General]
launchers=${LAUNCHER_STR}
iconSpacing=1

[Containments][3][Configuration]
PreloadWeight=100
APLRC

# ── plasmashellrc ─────────────────────────────────────────────────────────────
python3 - << PYEOF
import os

path = os.path.expanduser('$SHELLRC')
lines = []

if os.path.exists(path):
    with open(path) as f:
        skip = False
        for line in f:
            in_our_panel = '[PlasmaViews][Panel 2]' in line or '[PlasmaViews][Panel 3]' in line
            if in_our_panel:
                skip = True
            elif line.startswith('[') and skip and not in_our_panel:
                skip = False
            if not skip:
                lines.append(line)

# top bar — thin, full-width, flush to top edge
lines.append('\n[PlasmaViews][Panel 2][Defaults]\n')
lines.append('floating=0\n')
lines.append('panelLengthMode=1\n')
lines.append('panelVisibility=0\n')
lines.append('thickness=28\n')

# bottom dock — floating pill, centered, fit to content, auto-hide
lines.append('\n[PlasmaViews][Panel 3][Defaults]\n')
lines.append('floating=1\n')
lines.append('panelLengthMode=0\n')
lines.append('panelVisibility=1\n')
lines.append('thickness=60\n')

with open(path, 'w') as f:
    f.writelines(lines)

print('plasmashellrc written')
PYEOF

ok "panels configured"
set -e

# ══════════════════════════════════════════════════════════════════════════════
h "wallpapers"
# ══════════════════════════════════════════════════════════════════════════════

WALL_DIR="$HOME/.local/share/wallpapers/rice"
REPO_WALLS="$REPO_DIR/wallpapers"
mkdir -p "$WALL_DIR"

if [[ -d "$REPO_WALLS" ]]; then
  find "$REPO_WALLS" -maxdepth 1 \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -exec cp -n {} "$WALL_DIR/" \;
  COUNT=$(find "$WALL_DIR" -maxdepth 1 -type f | wc -l)
  ok "$COUNT wallpapers in $WALL_DIR"
else
  warn "wallpapers/ not found next to rice.sh"
fi

FIRST=$(find "$WALL_DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  | sort | head -1)

if [[ -n "$FIRST" ]]; then
  plasma-apply-wallpaperimage "$FIRST" 2>/dev/null && ok "wallpaper applied: $(basename "$FIRST")" || true
  qdbus6 org.kde.plasmashell /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript "
      var ds = desktops();
      for (var i = 0; i < ds.length; i++) {
        ds[i].wallpaperPlugin = 'org.kde.slideshow';
        ds[i].currentConfigGroup = ['Wallpaper','org.kde.slideshow','General'];
        ds[i].writeConfig('SlidePaths', '$WALL_DIR');
        ds[i].writeConfig('SlideInterval', 1800);
        ds[i].writeConfig('Shuffle', true);
      }
    " 2>/dev/null && ok "slideshow configured (30 min, shuffled)" || true
fi

# ══════════════════════════════════════════════════════════════════════════════
h "Ghostty theme"
# ══════════════════════════════════════════════════════════════════════════════

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
ok "Ghostty theme written"

# ══════════════════════════════════════════════════════════════════════════════
h "reload"
# ══════════════════════════════════════════════════════════════════════════════

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

log "restarting plasmashell..."
kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null || true
sleep 1
nohup plasmashell --replace &>/dev/null &
disown
sleep 3
ok "plasmashell restarted"

echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  rice done${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
echo -e "  ${C}top bar${D}     thin dark · full-width · 28px"
echo -e "  ${C}dock${D}        floating pill · bottom · ${#LAUNCHERS[@]} apps pinned"
echo -e "  ${C}colors${D}      Rosé Pine"
echo -e "  ${C}meta key${D}    opens window overview"
echo -e "  ${C}wallpaper${D}   slideshow from $WALL_DIR\n"
echo -e "  if dock apps show ? icons: right-click an icon → Properties → change icon"
echo -e "  to add/remove apps: right-click dock → Unlock → drag apps in/out\n"