#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  rice.sh — Niri + Quickshell setup
#  Rosé Pine · quickshell · fuzzel · mako · swaylock
#  idempotent: safe to re-run
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'
ok()  { echo -e "${G}✔${D} $*"; }
warn(){ echo -e "${Y}⚠${D}  $*"; }
h()   { echo -e "\n${W}━━━  $*  ━━━${D}"; }
log() { echo -e "${C}→${D} $*"; }

[[ $EUID -eq 0 ]] && { echo "run as normal user"; exit 1; }
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\n${W}  Niri rice — Rosé Pine + Quickshell${D}\n"

# ══════════════════════════════════════════════════════════════════════════════
h "packages"
# ══════════════════════════════════════════════════════════════════════════════

sudo pacman -S --needed --noconfirm \
  fuzzel mako swaylock grim slurp wl-clipboard \
  swaybg xdg-desktop-portal-gnome libnotify \
  papirus-icon-theme noto-fonts ttf-jetbrains-mono-nerd \
  brightnessctl network-manager-applet blueman

GIT_TERMINAL_PROMPT=0 PAGER=cat paru -S --needed --noconfirm \
  niri-bin quickshell-git bibata-cursor-theme \
  rose-pine-gtk-theme-full </dev/null 2>/dev/null || \
  warn "some AUR packages skipped"

ok "packages ready"

# ══════════════════════════════════════════════════════════════════════════════
h "environment"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/niri.conf" << 'ENV'
MOZ_ENABLE_WAYLAND=1
ELECTRON_OZONE_PLATFORM_HINT=wayland
QT_QPA_PLATFORM=wayland;xcb
QT_QPA_PLATFORMTHEME=gtk3
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
XDG_CURRENT_DESKTOP=niri
XDG_SESSION_TYPE=wayland
NIXOS_OZONE_WL=1
ENV
ok "environment set"

# ══════════════════════════════════════════════════════════════════════════════
h "wallpapers"
# ══════════════════════════════════════════════════════════════════════════════

WALL_DIR="$HOME/.local/share/wallpapers/rice"
mkdir -p "$WALL_DIR"
REPO_WALLS="$REPO_DIR/wallpapers"
if [[ -d "$REPO_WALLS" ]]; then
  find "$REPO_WALLS" -maxdepth 1 \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -exec cp -n {} "$WALL_DIR/" \;
  ok "$(find "$WALL_DIR" -maxdepth 1 -type f | wc -l) wallpapers in $WALL_DIR"
fi
FIRST_WALL=$(find "$WALL_DIR" -maxdepth 1 -type f | sort | head -1)

# ══════════════════════════════════════════════════════════════════════════════
h "niri config"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/niri"
WALL_PATH="${FIRST_WALL:-$WALL_DIR/wallpaper.png}"

cat > "$HOME/.config/niri/config.kdl" << NIRI
// ─── input ────────────────────────────────────────────────────────────────────
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

// ─── layout ───────────────────────────────────────────────────────────────────
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

// ─── look ─────────────────────────────────────────────────────────────────────
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

animations { slowdown 0.7 }

// ─── startup ──────────────────────────────────────────────────────────────────
spawn-at-startup "quickshell"
spawn-at-startup "mako"
spawn-at-startup "nm-applet" "--indicator"
spawn-at-startup "swaybg" "-m" "fill" "-i" "${WALL_PATH}"

// ─── binds ────────────────────────────────────────────────────────────────────
binds {
    Mod+Return        { spawn "ghostty"; }
    Mod+D             { spawn "fuzzel"; }
    Mod+E             { spawn "dolphin"; }
    Mod+B             { spawn "vivaldi-stable"; }
    Mod+L             { spawn "swaylock" "-f" "-c" "191724"; }

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
    Mod+Shift+Left    { move-column-left; }
    Mod+Shift+Right   { move-column-right; }
    Mod+Shift+Up      { move-window-up; }
    Mod+Shift+Down    { move-window-down; }

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
ok "niri config written"

# ══════════════════════════════════════════════════════════════════════════════
h "quickshell"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/quickshell"

cat > "$HOME/.config/quickshell/shell.qml" << 'QML'
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.SystemTray
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // ── Rosé Pine ─────────────────────────────────────────────────────────────
    readonly property color base:     "#191724"
    readonly property color surface:  "#1f1d2e"
    readonly property color overlay:  "#26233a"
    readonly property color muted:    "#6e6a86"
    readonly property color subtle:   "#908caa"
    readonly property color text:     "#e0def4"
    readonly property color love:     "#eb6f92"
    readonly property color gold:     "#f6c177"
    readonly property color foam:     "#9ccfd8"

    // ── niri workspaces (poll via niri msg) ───────────────────────────────────
    property var workspaces: []

    Process {
        id: wsProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try { root.workspaces = JSON.parse(data) } catch (_) {}
            }
        }
        onExited: running = false
    }

    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!wsProc.running) wsProc.running = true
    }

    // ── volume via wpctl ──────────────────────────────────────────────────────
    property real  vol: 0
    property bool  mute: false

    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/Volume:\s+([\d.]+)(\s+\[MUTED\])?/)
                if (m) { root.vol = parseFloat(m[1]); root.mute = !!m[2] }
            }
        }
        onExited: running = false
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!volProc.running) volProc.running = true
    }

    // ── bar — one per screen ──────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: "transparent"
            WlrLayershell.namespace: "qs-bar"
            WlrLayershell.exclusiveZone: 32

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.098, 0.090, 0.141, 0.94)   // base #191724

                RowLayout {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
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
                                color: modelData.is_focused ? root.love : root.overlay
                                font { pixelSize: 11; family: "Noto Sans" }
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // clock
                    Text {
                        text: Qt.formatDateTime(SystemClock.time, "hh:mm   yyyy-MM-dd")
                        color: root.text
                        font { pixelSize: 13; family: "Noto Sans"; weight: Font.Medium }
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // volume
                    Row {
                        spacing: 5
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 14

                        Text {
                            text: root.mute ? "󰖁" : (root.vol > 0.6 ? "󰕾" : root.vol > 0.2 ? "󰖀" : "󰕿")
                            color: root.mute ? root.muted : root.subtle
                            font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: root.mute ? "mute" : `${Math.round(root.vol * 100)}%`
                            color: root.subtle
                            font { pixelSize: 12; family: "Noto Sans" }
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // battery
                    Repeater {
                        model: UPower.devices.values.filter(d => d.isLaptopBattery)

                        Row {
                            required property var modelData
                            spacing: 5
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 14

                            Text {
                                text: {
                                    if (modelData.state === UPowerDeviceState.Charging) return "⚡"
                                    const p = modelData.percentage
                                    if (p > 0.85) return "󰁹"
                                    if (p > 0.6)  return "󰂁"
                                    if (p > 0.4)  return "󰁿"
                                    if (p > 0.2)  return "󰁽"
                                    return "󰁺"
                                }
                                color: {
                                    const p = modelData.percentage
                                    if (p < 0.15) return root.love
                                    if (p < 0.3)  return root.gold
                                    return root.subtle
                                }
                                font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                                verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                text: `${Math.round(modelData.percentage * 100)}%`
                                color: root.subtle
                                font { pixelSize: 12; family: "Noto Sans" }
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // system tray
                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter

                        Repeater {
                            model: SystemTray.items.values

                            Item {
                                required property var modelData
                                width: 18; height: 18

                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => mouse.button === Qt.LeftButton
                                        ? modelData.activate()
                                        : modelData.secondaryActivate()
                                }
                            }
                        }
                    }

                } // RowLayout
            } // Rectangle
        } // PanelWindow
    } // Variants
} // ShellRoot
QML
ok "quickshell shell.qml written"

# ══════════════════════════════════════════════════════════════════════════════
h "fuzzel"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/fuzzel"
cat > "$HOME/.config/fuzzel/fuzzel.ini" << 'FUZZEL'
[main]
font=Noto Sans:size=13
dpi-aware=no
width=35
lines=8
tabs=4
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

[dmenu]
exit-immediately-if-empty=yes
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
icons=1
icon-location=left
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
inside-color=191724
ring-color=26233a
ring-clear-color=9ccfd8
ring-ver-color=31748f
ring-wrong-color=eb6f92
key-hl-color=eb6f92
bs-hl-color=f6c177
text-color=e0def4
text-wrong-color=eb6f92
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
GTK4

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
ok "GTK, cursor, fonts configured"

# ══════════════════════════════════════════════════════════════════════════════
h "power"
# ══════════════════════════════════════════════════════════════════════════════

cat > "$HOME/.config/powermanagementprofilesrc" << 'POWER'
[AC][BrightnessControl]
value=100

[AC][DimDisplay]
idleTime=0

[AC][DPMSControl]
idleTime=0
lockBeforeTurnOff=0

[AC][HandleButtonEvents]
lidAction=0
powerButtonAction=1

[AC][SuspendSession]
idleTime=0
suspendThenHibernate=false
suspendType=0

[Battery][BrightnessControl]
value=80

[Battery][DimDisplay]
idleTime=120000

[Battery][DPMSControl]
idleTime=300000
lockBeforeTurnOff=1

[Battery][HandleButtonEvents]
lidAction=1
powerButtonAction=1

[Battery][SuspendSession]
idleTime=1200000
suspendThenHibernate=false
suspendType=1

[LowBattery][BrightnessControl]
value=50

[LowBattery][DimDisplay]
idleTime=60000

[LowBattery][DPMSControl]
idleTime=120000
lockBeforeTurnOff=1

[LowBattery][SuspendSession]
idleTime=300000
suspendThenHibernate=true
suspendType=1
POWER
ok "power management configured"

# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  Niri rice done${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
echo -e "  ${C}log in:${D}     select Niri from SDDM session menu"
echo -e "  ${C}terminal:${D}   Mod+Return"
echo -e "  ${C}launcher:${D}   Mod+D"
echo -e "  ${C}close:${D}      Mod+Q"
echo -e "  ${C}lock:${D}       Mod+L"
echo -e "  ${C}quit niri:${D}  Mod+Shift+E\n"