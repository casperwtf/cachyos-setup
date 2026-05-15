#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  rice.sh — Niri + Noctalia Shell
#  Rosé Pine · fuzzel · mako · swaylock
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'
ok()  { echo -e "${G}✔${D} $*"; }
warn(){ echo -e "${Y}⚠${D}  $*"; }
h()   { echo -e "\n${W}━━━  $*  ━━━${D}"; }

[[ $EUID -eq 0 ]] && { echo "run as normal user"; exit 1; }
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\n${W}  Niri + Noctalia Shell — Rosé Pine${D}\n"

# ══════════════════════════════════════════════════════════════════════════════
h "packages"
# ══════════════════════════════════════════════════════════════════════════════

sudo pacman -S --needed --noconfirm \
  fuzzel mako swaylock grim slurp wl-clipboard swaybg \
  xdg-desktop-portal-gnome network-manager-applet \
  papirus-icon-theme noto-fonts ttf-jetbrains-mono-nerd \
  libnotify brightnessctl xwayland-satellite

GIT_TERMINAL_PROMPT=0 PAGER=cat \
  paru -S --needed --noconfirm \
  niri-bin noctalia-shell bibata-cursor-theme \
  rose-pine-gtk-theme-full \
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
ok "wallpapers: $(find "$WALL_DIR" -maxdepth 1 -type f | wc -l) files"

# ══════════════════════════════════════════════════════════════════════════════
h "niri config"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/niri"
SWAYBG_LINE=""
[[ -n "${WALL:-}" ]] && SWAYBG_LINE="spawn-at-startup \"swaybg\" \"-m\" \"fill\" \"-i\" \"${WALL}\""

cat > "$HOME/.config/niri/config.kdl" << NIRI
prefer-no-csd

input {
    keyboard {
        xkb {
            layout "us"
        }
        repeat-delay 200
        repeat-rate 35
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
    gaps 0

    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
    }

    default-column-width { proportion 0.5; }

    focus-ring {
        width 1.5
        active-color "#eb6f92"
        inactive-color "#26233a"
    }

    border { off }

    struts { top 32 }
}

cursor {
    theme "bibata-modern-classic"
    size 24
}

screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

hotkey-overlay { skip-at-startup }

window-rule {
    geometry-corner-radius 4
    clip-to-geometry true
}

// 1password — force float so popup appears
window-rule {
    app-id r#"^1password$"#
    open-floating true
}
window-rule {
    title r#"^1Password —"#
    open-floating true
    default-column-width { fixed 400; }
}

animations { slowdown 0.7 }

spawn-at-startup "noctalia-shell"
spawn-at-startup "mako"
spawn-at-startup "nm-applet" "--indicator"
spawn-at-startup "xwayland-satellite"
${SWAYBG_LINE}

binds {
    Mod+Return hotkey-overlay-title="Open Terminal: ghostty" { spawn "ghostty"; }
    Mod+D      hotkey-overlay-title="Run Application: fuzzel" { spawn "fuzzel"; }
    Mod+E      hotkey-overlay-title="File Manager: dolphin"   { spawn "dolphin"; }
    Mod+B      hotkey-overlay-title="Browser: vivaldi"        { spawn "vivaldi-stable"; }
    Mod+Shift+L hotkey-overlay-title="Lock Screen"            { spawn "swaylock" "-f" "-c" "191724"; }

    Print       { screenshot; }
    Mod+S       { screenshot; }
    Ctrl+Print  { screenshot-screen; }
    Alt+Print   { screenshot-window; }

    Mod+Q { close-window; }
    Mod+O { overview-toggle; }
    Mod+F { maximize-column; }
    Mod+Shift+F { fullscreen-window; }
    Mod+C { center-column; }
    Mod+R { switch-preset-column-width; }
    Mod+Shift+R { reset-window-height; }

    Mod+H     { focus-column-left; }
    Mod+J     { focus-window-down; }
    Mod+K     { focus-window-up; }
    Mod+L     { focus-column-right; }
    Mod+Left  { focus-column-left; }
    Mod+Right { focus-column-right; }
    Mod+Up    { focus-window-up; }
    Mod+Down  { focus-window-down; }

    Mod+Shift+H     { move-column-left; }
    Mod+Shift+J     { move-window-down; }
    Mod+Shift+K     { move-window-up; }
    Mod+Shift+L     { move-column-right; }
    Mod+Shift+Left  { move-column-left; }
    Mod+Shift+Right { move-column-right; }
    Mod+Shift+Up    { move-window-up; }
    Mod+Shift+Down  { move-window-down; }

    Mod+1 { focus-workspace 1; }
    Mod+2 { focus-workspace 2; }
    Mod+3 { focus-workspace 3; }
    Mod+4 { focus-workspace 4; }
    Mod+5 { focus-workspace 5; }
    Mod+6 { focus-workspace 6; }
    Mod+7 { focus-workspace 7; }
    Mod+8 { focus-workspace 8; }
    Mod+9 { focus-workspace 9; }

    Mod+Shift+1 { move-column-to-workspace 1; }
    Mod+Shift+2 { move-column-to-workspace 2; }
    Mod+Shift+3 { move-column-to-workspace 3; }
    Mod+Shift+4 { move-column-to-workspace 4; }
    Mod+Shift+5 { move-column-to-workspace 5; }
    Mod+Shift+6 { move-column-to-workspace 6; }
    Mod+Shift+7 { move-column-to-workspace 7; }
    Mod+Shift+8 { move-column-to-workspace 8; }
    Mod+Shift+9 { move-column-to-workspace 9; }

    Mod+Tab       { focus-workspace-previous; }
    Mod+Page_Down { focus-workspace-down; }
    Mod+Page_Up   { focus-workspace-up; }

    Mod+Minus       { set-column-width "-10%"; }
    Mod+Equal       { set-column-width "+10%"; }
    Mod+Shift+Minus { set-window-height "-10%"; }
    Mod+Shift+Equal { set-window-height "+10%"; }

    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

    Mod+Shift+E { quit; }
    Mod+Shift+P { power-off-monitors; }

    XF86AudioRaiseVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
    XF86AudioLowerVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
    XF86AudioMute         allow-when-locked=true { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }
    XF86AudioMicMute      allow-when-locked=true { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
    XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }
}
NIRI

command -v niri &>/dev/null && \
  niri validate --config "$HOME/.config/niri/config.kdl" 2>&1 | head -5 || true
ok "niri config written"

# ══════════════════════════════════════════════════════════════════════════════
h "noctalia shell"
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$HOME/.config/quickshell/noctalia"

cat > "$HOME/.config/quickshell/noctalia/settings.json" << JSON
{
    "bar": {
        "position": "top",
        "widgets": {
            "left": [
                { "id": "SystemMonitor", "showCpuTemp": false, "showCpuUsage": true, "showMemoryUsage": true },
                { "id": "ActiveWindow", "showIcon": true, "maxWidth": 200 },
                { "id": "MediaMini", "maxWidth": 150 }
            ],
            "center": [
                { "id": "Workspace", "labelMode": "number", "hideUnoccupied": true }
            ],
            "right": [
                { "id": "Tray" },
                { "id": "Battery" },
                { "id": "Volume" },
                { "id": "Clock", "formatHorizontal": "HH:mm  yyyy-MM-dd" },
                { "id": "ControlCenter" }
            ]
        }
    },
    "wallpaper": {
        "directory": "${WALL_DIR}",
        "enabled": true,
        "fillMode": "crop",
        "randomEnabled": true,
        "randomIntervalSec": 1800,
        "transitionDuration": 1000
    },
    "colorSchemes": {
        "darkMode": true,
        "predefinedScheme": "Rosé Pine"
    },
    "ui": {
        "fontDefault": "JetBrainsMono Nerd Font Propo",
        "borderRadius": 4
    }
}
JSON
ok "noctalia settings written"

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
radius=4
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
border-radius=4
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

if command -v gsettings &>/dev/null && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  gsettings set org.gnome.desktop.interface color-scheme          prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme             rose-pine
  gsettings set org.gnome.desktop.interface icon-theme            Papirus-Dark
  gsettings set org.gnome.desktop.interface cursor-theme          bibata-modern-classic
  gsettings set org.gnome.desktop.interface font-name             "Noto Sans 11"
  gsettings set org.gnome.desktop.interface monospace-font-name   "JetBrainsMono Nerd Font 12"
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
_1PASSWORD_SKIP_APPINDICATOR=1
ENV

mkdir -p "$HOME/.config/1Password"
cat > "$HOME/.config/1Password/flags" << 'FLAGS'
--enable-features=UseOzonePlatform,WaylandWindowDecorations
--ozone-platform=wayland
--disable-gpu-sandbox
FLAGS
ok "environment set"

# ══════════════════════════════════════════════════════════════════════════════
# live reload if inside niri
if [[ "${XDG_CURRENT_DESKTOP:-}" == "niri" ]]; then
  h "reloading"
  niri msg action reload-config 2>/dev/null || true
  pkill -x noctalia-shell 2>/dev/null || true; sleep 0.5
  nohup noctalia-shell &>/dev/null & disown
  pkill -x mako 2>/dev/null || true; sleep 0.3
  nohup mako &>/dev/null & disown
  ok "reloaded"
fi

echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  done${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
[[ "${XDG_CURRENT_DESKTOP:-}" != "niri" ]] && \
  echo -e "  ${Y}log out → select Niri from SDDM session picker${D}\n"
echo -e "  ${C}Mod+Return${D}   terminal  |  ${C}Mod+D${D}  launcher  |  ${C}Mod+O${D}  overview"
echo -e "  ${C}Mod+Q${D}        close     |  ${C}Mod+1-9${D} workspaces\n"