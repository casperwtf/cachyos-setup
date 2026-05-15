#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  rice.sh — Niri + Quickshell
#  Rosé Pine · fuzzel · mako · swaylock
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'
ok()  { echo -e "${G}✔${D} $*"; }
warn(){ echo -e "${Y}⚠${D}  $*"; }
h()   { echo -e "\n${W}━━━  $*  ━━━${D}"; }

[[ $EUID -eq 0 ]] && { echo "run as normal user"; exit 1; }
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN_NIRI=[[ "${XDG_CURRENT_DESKTOP:-}" == "niri" ]] && echo true || echo false

# ══════════════════════════════════════════════════════════════════════════════
h "packages"
# ══════════════════════════════════════════════════════════════════════════════

sudo pacman -S --needed --noconfirm \
  fuzzel mako swaylock grim slurp wl-clipboard swaybg \
  xdg-desktop-portal-gnome network-manager-applet \
  papirus-icon-theme noto-fonts ttf-jetbrains-mono-nerd \
  libnotify brightnessctl

GIT_TERMINAL_PROMPT=0 PAGER=cat \
  paru -S --needed --noconfirm niri-bin quickshell-git \
  bibata-cursor-theme rose-pine-gtk-theme-full \
  </dev/null 2>/dev/null || warn "some AUR packages skipped"

ok "packages done"

# ══════════════════════════════════════════════════════════════════════════════
h "wallpapers"
# ══════════════════════════════════════════════════════════════════════════════

WALL_DIR="$HOME/.local/share/wallpapers/rice"
mkdir -p "$WALL_DIR"
[[ -d "$REPO_DIR/wallpapers" ]] && \
  find "$REPO_DIR/wallpapers" -maxdepth 1 \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -exec cp -n {} "$WALL_DIR/" \;
WALL=$(find "$WALL_DIR" -maxdepth 1 -type f | sort | head -1)
WALL="${WALL:-}"
ok "wallpapers: $(find "$WALL_DIR" -maxdepth 1 -type f | wc -l) files"

# ══════════════════════════════════════════════════════════════════════════════
h "niri config"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/niri"
SWAYBG_LINE=""
[[ -n "$WALL" ]] && SWAYBG_LINE="spawn-at-startup \"swaybg\" \"-m\" \"fill\" \"-i\" \"${WALL}\""

cat > "$HOME/.config/niri/config.kdl" << NIRI
input {
    keyboard {
        xkb { layout "us" }
        repeat-delay 300
        repeat-rate 50
    }
    touchpad {
        tap
        dwt
        natural-scroll
        scroll-method "two-finger"
        accel-speed 0.2
        accel-profile "adaptive"
    }
    mouse {
        accel-speed 0.0
        accel-profile "flat"
    }
    focus-follows-mouse max-scroll-amount="0%"
}

layout {
    gaps 12
    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
    }
    default-column-width { proportion 0.5; }
    focus-ring {
        width 2
        active-color "#eb6f92"
        inactive-color "#26233a"
    }
    border { off }
    struts { top 32 }
}

prefer-no-csd

cursor {
    theme "bibata-modern-classic"
    size 24
}

screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"
hotkey-overlay { skip-at-startup }

window-rule {
    geometry-corner-radius 8
    clip-to-geometry true
}

// 1password — force float so the popup/quick-access window actually appears
window-rule {
    app-id r#"^1password$"#
    open-floating true
}

// 1password quick access (separate popup window)
window-rule {
    title r#"^1Password —"#
    open-floating true
    default-column-width { fixed 400; }
}

animations { slowdown 0.7 }

spawn-at-startup "quickshell"
spawn-at-startup "mako"
spawn-at-startup "nm-applet" "--indicator"
${SWAYBG_LINE}

binds {
    Mod+Return        { spawn "ghostty"; }
    Mod+D             { spawn "fuzzel"; }
    Mod+E             { spawn "dolphin"; }
    Mod+B             { spawn "vivaldi-stable"; }
    Mod+Shift+L       { spawn "swaylock" "-f" "-c" "191724"; }

    Print             { screenshot; }
    Mod+Shift+S       { screenshot; }
    Mod+S             { screenshot-screen; }

    Mod+Q             { close-window; }
    Mod+F             { maximize-column; }
    Mod+Shift+F       { fullscreen-window; }
    Mod+C             { center-column; }
    Mod+R             { switch-preset-column-width; }
    Mod+Shift+R       { reset-window-height; }

    Mod+H             { focus-column-left; }
    Mod+J             { focus-window-down; }
    Mod+K             { focus-window-up; }
    Mod+L             { focus-column-right; }
    Mod+Left          { focus-column-left; }
    Mod+Right         { focus-column-right; }
    Mod+Up            { focus-window-up; }
    Mod+Down          { focus-window-down; }

    Mod+Shift+H       { move-column-left; }
    Mod+Shift+J       { move-window-down; }
    Mod+Shift+K       { move-window-up; }
    Mod+Shift+L       { move-column-right; }

    Mod+1             { focus-workspace 1; }
    Mod+2             { focus-workspace 2; }
    Mod+3             { focus-workspace 3; }
    Mod+4             { focus-workspace 4; }
    Mod+5             { focus-workspace 5; }
    Mod+Shift+1       { move-window-to-workspace 1; }
    Mod+Shift+2       { move-window-to-workspace 2; }
    Mod+Shift+3       { move-window-to-workspace 3; }
    Mod+Shift+4       { move-window-to-workspace 4; }
    Mod+Shift+5       { move-window-to-workspace 5; }
    Mod+Tab           { focus-workspace-previous; }
    Mod+Page_Down     { focus-workspace-down; }
    Mod+Page_Up       { focus-workspace-up; }

    Mod+Minus         { set-column-width "-10%"; }
    Mod+Equal         { set-column-width "+10%"; }
    Mod+Shift+Minus   { set-window-height "-10%"; }
    Mod+Shift+Equal   { set-window-height "+10%"; }

    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

    Mod+Shift+E       { quit; }
    Mod+Shift+P       { power-off-monitors; }

    XF86AudioRaiseVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
    XF86AudioLowerVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
    XF86AudioMute         allow-when-locked=true { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }
    XF86AudioMicMute      allow-when-locked=true { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
    XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }
}
NIRI

# validate config if niri is installed
command -v niri &>/dev/null && \
  niri validate --config "$HOME/.config/niri/config.kdl" 2>&1 | \
  grep -v '^$' | head -5 || true

ok "niri config written"

# ══════════════════════════════════════════════════════════════════════════════
h "quickshell"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/quickshell"

cat > "$HOME/.config/quickshell/shell.qml" << 'QML'
// Rosé Pine bar for Niri
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // palette
    readonly property string colBase:    "#f0191724"
    readonly property string colText:    "#e0def4"
    readonly property string colSubtle:  "#908caa"
    readonly property string colMuted:   "#6e6a86"
    readonly property string colOverlay: "#26233a"
    readonly property string colLove:    "#eb6f92"
    readonly property string colGold:    "#f6c177"

    // clock
    property var now: new Date()
    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // niri workspaces
    property var workspaces: []
    Process {
        id: wsProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try { root.workspaces = JSON.parse(data) } catch(_) {}
            }
        }
        onExited: running = false
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!wsProc.running) wsProc.running = true
    }

    // volume
    property string volText: ""
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'N/A'"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/Volume:\s+([\d.]+)(\s+\[MUTED\])?/)
                if (m) root.volText = m[2]
                    ? "󰖁 mute"
                    : `${parseFloat(m[1]) > 0.5 ? "󰕾" : "󰖀"} ${Math.round(parseFloat(m[1])*100)}%`
            }
        }
        onExited: running = false
    }
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!volProc.running) volProc.running = true
    }

    // battery
    property string batText: ""
    Process {
        id: batProc
        command: ["bash", "-c", `
            BAT=/sys/class/power_supply/BAT0
            [ -f $BAT/capacity ] || exit 0
            CAP=$(cat $BAT/capacity)
            STA=$(cat $BAT/status)
            [ "$STA" = "Charging" ] && ICON="⚡" || ICON="🔋"
            echo "$ICON ${CAP}%"
        `]
        stdout: SplitParser { onRead: data => root.batText = data.trim() }
        onExited: running = false
    }
    Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!batProc.running) batProc.running = true
    }

    // one bar per screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: "transparent"
            WlrLayershell.exclusiveZone: 32

            Rectangle {
                anchors.fill: parent
                color: root.colBase

                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 0

                    // workspaces
                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Repeater {
                            model: root.workspaces
                            Text {
                                required property var modelData
                                text: modelData.is_focused ? "●" : "○"
                                color: modelData.is_focused ? root.colLove : root.colOverlay
                                font.pixelSize: 11
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // clock
                    Text {
                        text: Qt.formatDateTime(root.now, "hh:mm   yyyy-MM-dd")
                        color: root.colText
                        font { pixelSize: 13; family: "Noto Sans"; weight: Font.Medium }
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // volume
                    Text {
                        text: root.volText
                        color: root.colSubtle
                        font { pixelSize: 12; family: "JetBrainsMono Nerd Font" }
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 14
                        visible: root.volText !== ""
                    }

                    // battery
                    Text {
                        text: root.batText
                        color: root.colSubtle
                        font { pixelSize: 12; family: "Noto Sans" }
                        Layout.alignment: Qt.AlignVCenter
                        visible: root.batText !== ""
                    }
                }
            }
        }
    }
}
QML
ok "quickshell shell.qml written"

# ══════════════════════════════════════════════════════════════════════════════
h "fuzzel"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/fuzzel"
cat > "$HOME/.config/fuzzel/fuzzel.ini" << 'FUZZEL'
[main]
font=Noto Sans:size=13
width=35
lines=8
horizontal-pad=20
vertical-pad=12
inner-pad=8
anchor=center
layer=overlay

[colors]
background=191724ff
text=e0def4ff
match=eb6f92ff
selection=26233aff
selection-text=e0def4ff
selection-match=eb6f92ff
border=26233aff

[border]
width=1
radius=8
FUZZEL
ok "fuzzel configured"

# ══════════════════════════════════════════════════════════════════════════════
h "mako"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/mako"
cat > "$HOME/.config/mako/config" << 'MAKO'
sort=-time
layer=overlay
background-color=#1f1d2e
text-color=#e0def4
width=360
height=120
border-size=1
border-color=#26233a
border-radius=8
max-icon-size=48
default-timeout=5000
font=Noto Sans 13
margin=12
padding=12,16

[urgency=high]
border-color=#eb6f92
default-timeout=0
MAKO
ok "mako configured"

# ══════════════════════════════════════════════════════════════════════════════
h "swaylock"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/swaylock"
cat > "$HOME/.config/swaylock/config" << 'SWAYLOCK'
color=191724
ring-color=26233a
ring-clear-color=9ccfd8
ring-ver-color=31748f
ring-wrong-color=eb6f92
key-hl-color=eb6f92
text-color=e0def4
indicator-radius=80
indicator-thickness=8
font=Noto Sans
SWAYLOCK
ok "swaylock configured"

# ══════════════════════════════════════════════════════════════════════════════
h "GTK + cursor + fonts"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.icons/default"

cat > "$HOME/.config/gtk-3.0/settings.ini" << 'GTK3'
[Settings]
gtk-theme-name=rose-pine
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=bibata-modern-classic
gtk-font-name=Noto Sans 11
gtk-application-prefer-dark-theme=1
GTK3

cat > "$HOME/.config/gtk-4.0/settings.ini" << 'GTK4'
[Settings]
gtk-theme-name=rose-pine
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=bibata-modern-classic
gtk-font-name=Noto Sans 11
gtk-application-prefer-dark-theme=1
gtk-color-scheme=prefer-dark
GTK4

# set via gsettings so libadwaita/GNOME apps respect it
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface color-scheme     prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme        rose-pine
  gsettings set org.gnome.desktop.interface icon-theme       Papirus-Dark
  gsettings set org.gnome.desktop.interface cursor-theme     bibata-modern-classic
  gsettings set org.gnome.desktop.interface font-name        "Noto Sans 11"
  gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 12"
fi

cat > "$HOME/.icons/default/index.theme" << 'CURSOR'
[Icon Theme]
Name=Default
Inherits=bibata-modern-classic
CURSOR

grep -q 'Xcursor.theme' "$HOME/.Xresources" 2>/dev/null || \
  printf 'Xcursor.theme: bibata-modern-classic\nXcursor.size: 24\n' >> "$HOME/.Xresources"

mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'FONTCONF'
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="rgba"      mode="assign"><const>rgb</const></edit>
    <edit name="hinting"   mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
  </match>
  <alias><family>monospace</family>
    <prefer><family>JetBrainsMono Nerd Font</family></prefer></alias>
  <alias><family>sans-serif</family>
    <prefer><family>Noto Sans</family></prefer></alias>
</fontconfig>
FONTCONF
fc-cache -fv &>/dev/null
ok "GTK, cursor, fonts done"

# ══════════════════════════════════════════════════════════════════════════════
h "environment"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/niri.conf" << 'ENV'
MOZ_ENABLE_WAYLAND=1
ELECTRON_OZONE_PLATFORM_HINT=wayland
QT_QPA_PLATFORM=wayland;xcb
QT_QPA_PLATFORMTHEME=gtk3
GTK_THEME=rose-pine
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
XDG_CURRENT_DESKTOP=niri
XDG_SESSION_TYPE=wayland
NIXOS_OZONE_WL=1
# 1Password — needed for popup to work on non-GNOME/KDE Wayland
_1PASSWORD_SKIP_APPINDICATOR=1
ENV

# 1Password CLI flags — force Wayland + allow popup via xdg-activation
mkdir -p "$HOME/.config/1Password"
cat > "$HOME/.config/1Password/flags" << 'FLAGS'
--enable-features=UseOzonePlatform,WaylandWindowDecorations
--ozone-platform=wayland
--disable-gpu-sandbox
FLAGS
ok "environment set"

# ══════════════════════════════════════════════════════════════════════════════
# if already inside a niri session, restart services live
# ══════════════════════════════════════════════════════════════════════════════
if [[ "${XDG_CURRENT_DESKTOP:-}" == "niri" ]]; then
  h "reloading live services"
  pkill -x quickshell 2>/dev/null || true; sleep 0.5
  nohup quickshell &>/dev/null & disown
  pkill -x mako 2>/dev/null || true; sleep 0.3
  nohup mako &>/dev/null & disown
  niri msg action reload-config 2>/dev/null || true
  ok "services restarted"
fi

# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  rice done${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
if [[ "${XDG_CURRENT_DESKTOP:-}" != "niri" ]]; then
  echo -e "  ${Y}not in a niri session — configs written but not active yet${D}"
  echo -e "  log out and select ${W}Niri${D} from the SDDM session picker\n"
fi
echo -e "  ${C}Mod${D} = Super/Win key"
echo -e "  ${C}Mod+Return${D}    terminal"
echo -e "  ${C}Mod+D${D}         launcher"
echo -e "  ${C}Mod+Q${D}         close window"
echo -e "  ${C}Mod+Shift+L${D}   lock screen"
echo -e "  ${C}Mod+Shift+E${D}   quit niri\n"