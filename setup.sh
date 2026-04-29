#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  CachyOS KDE — Game Dev Setup
#  Scope: Java/C#/general dev, browsers, comms, DevOps, gaming
#
#  Structure:
#    Phase 0  — sudo, system update, paru               (sequential)
#    Phase 1  — terminal + shell config                 (sequential)
#    Phase 2  — single pacman batch + single AUR batch  (sequential, can't parallelize pacman)
#    Phase 3  — all config/service/file writes          (parallel background jobs)
#    Phase 4  — JDK detection, fnm, post-install steps  (sequential)
#    Phase 5  — wizard                                  (interactive)
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail
IFS=$'\n\t'

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
C='\033[0;36m' W='\033[1;37m' D='\033[0m'

log()     { echo -e "${C}→${D} $*"; }
ok()      { echo -e "${G}✔${D} $*"; }
warn()    { echo -e "${Y}⚠${D}  $*"; }
die()     { echo -e "${R}✖${D} $*" >&2; exit 1; }
section() { echo -e "\n${W}━━━  $*  ━━━${D}"; }

pacin()  { sudo pacman -S --needed --noconfirm "$@"; }
aurin()  { paru  -S --needed --noconfirm "$@" 2>/dev/null || warn "AUR miss: $*"; }

[[ $EUID -eq 0 ]]            && die "Run as your normal user, not root."
command -v pacman &>/dev/null || die "pacman not found."

clear
echo -e "${W}"
cat << 'BANNER'
  ╔═══════════════════════════════════════════════╗
  ║     CachyOS KDE  ·  Game Dev Setup            ║
  ║     Java · C# · Node · Python · DevOps        ║
  ╚═══════════════════════════════════════════════╝
BANNER
echo -e "${D}"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 0 — sudo · system update · paru
# ══════════════════════════════════════════════════════════════════════════════
section "Phase 0 — sudo · update · paru"

SUDOERS_FILE="/etc/sudoers.d/nopasswd-wheel"
if [[ ! -f "$SUDOERS_FILE" ]]; then
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" >/dev/null
  sudo chmod 440 "$SUDOERS_FILE"
  ok "Passwordless sudo → wheel group."
fi

log "System upgrade..."
sudo pacman -Syu --noconfirm

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  log "Enabling multilib..."
  sudo sed -i '/^#\[multilib\]/{n;s/^#//};/^#\[multilib\]/s/^#//' /etc/pacman.conf
  sudo pacman -Sy --noconfirm
fi

if ! command -v paru &>/dev/null; then
  log "Building paru..."
  pacin git base-devel
  T=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$T/paru"
  pushd "$T/paru" >/dev/null; makepkg -si --noconfirm; popd >/dev/null
  rm -rf "$T"
fi
ok "Phase 0 done."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — terminal + shell config (sequential — other phases read these files)
# ══════════════════════════════════════════════════════════════════════════════
section "Phase 1 — terminal · fish · starship · ghostty"

aurin ghostty
pacin fish starship zoxide fzf fd ripgrep bat eza tmux

chsh -s "$(command -v fish)"
ok "Default shell → fish."

FISH_CFG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CFG")"
cat > "$FISH_CFG" << 'FISH'
starship init fish | source
zoxide init fish | source

alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

function jdk
    if test -z "$argv[1]"
        archlinux-java status
        return
    end
    sudo archlinux-java set "java-$argv[1]-openjdk"
    set -gx JAVA_HOME /usr/lib/jvm/java-$argv[1]-openjdk
    echo "→ "(java -version 2>&1 | head -1)
end

if command -q fnm
    fnm env --use-on-cd | source
end

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
FISH

cat > "$HOME/.config/starship.toml" << 'STAR'
format = """
$directory$git_branch$git_status$java$kotlin$nodejs$python$rust$docker_context$line_break$character"""
add_newline = true

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"

[directory]
style             = "bold cyan"
truncation_length = 3
truncate_to_repo  = true

[git_branch]
format = " [on](dim white) [$symbol$branch](bold purple)"
symbol = " "

[git_status]
format     = "([$all_status$ahead_behind]($style) )"
style      = "bold yellow"
conflicted = "⚡"
ahead      = "⇡${count}"
behind     = "⇣${count}"
modified   = "!${count}"
untracked  = "?${count}"
staged     = "+${count}"

[java]
format       = " [☕ $version](bold red)"
detect_files = ["pom.xml","build.gradle","*.java"]

[kotlin]
format = " [kotlin $version](bold blue)"

[nodejs]
format = " [node $version](bold green)"

[python]
format = " [py $version](bold yellow)"

[docker_context]
format = " [🐳 $context](bold blue)"

[time]
disabled    = false
format      = "[$time](dim white) "
time_format = "%H:%M"
STAR

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ghostty/themes"

# Write the rose-pine theme file — Ghostty looks for it in ~/.config/ghostty/themes/
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
cat > "$HOME/.config/ghostty/config" << 'GHOSTTY'
theme                = rose-pine
font-family          = JetBrainsMono Nerd Font
font-size            = 13
font-thicken         = true
window-decoration    = false
window-padding-x     = 12
window-padding-y     = 8
background-opacity   = 0.97
background-blur-radius = 20
shell-integration    = fish
scrollback-limit     = 10000
copy-on-select       = clipboard
cursor-style         = bar
cursor-style-blink   = true
gtk-tabs-location    = bottom
gtk-wide-tabs        = false
keybind = ctrl+shift+t=new_tab
keybind = ctrl+shift+w=close_surface
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = ctrl+equal=increase_font_size:1
keybind = ctrl+minus=decrease_font_size:1
keybind = ctrl+zero=reset_font_size
keybind = ctrl+shift+d=new_split:right
keybind = ctrl+shift+e=new_split:down
keybind = ctrl+shift+left_bracket=goto_split:previous
keybind = ctrl+shift+right_bracket=goto_split:next
GHOSTTY

ok "Phase 1 done."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — package installs  (pacman can't run concurrently — one batch each)
# ══════════════════════════════════════════════════════════════════════════════
section "Phase 2 — installing all packages"

# ── Official repos — one call ─────────────────────────────────────────────────
log "pacman batch..."
pacin \
  `# fonts` \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-liberation ttf-dejavu otf-font-awesome \
  `# KDE tooling` \
  kvantum qt5ct qt6ct \
  `# browsers` \
  chromium \
  `# comms` \
  discord signal-desktop \
  `# dev base` \
  git python python-pip python-virtualenv github-cli \
  `# docker` \
  docker docker-compose docker-buildx \
  `# db clients` \
  sqlitebrowser \
  `# android` \
  android-tools android-udev scrcpy gvfs-mtp \
  `# gaming` \
  steam gamemode lib32-gamemode mangohud lib32-mangohud \
  `# vpn/net` \
  wireguard-tools tailscale wireshark-qt \
  `# devops` \
  `# productivity` \
  thunderbird \
  `# media` \
  obs-studio audacity v4l2loopback-dkms flameshot \
  `# tweaks` \
  reflector zram-generator irqbalance \
  `# power + keyboard` \
  cpupower brightnessctl power-profiles-daemon
ok "pacman batch done."

# ── AUR — one call ────────────────────────────────────────────────────────────
log "AUR batch..."
aurin \
  `# terminal` \
  `# fonts` \
  ttf-ms-win11-auto \
  `# KDE theme` \
  catppuccin-kde-git papirus-icon-theme bibata-cursor-theme klassy \
  `# browsers` \
  vivaldi vivaldi-ffmpeg-codecs librewolf-bin ungoogled-chromium-bin tor-browser \
  `# comms` \
  discord-canary slack-desktop rocketchat-desktop \
  `# editors` \
  zed visual-studio-code-bin jetbrains-toolbox \
  `# dev` \
  fnm-bin bun-bin \
  `# docker` \
  docker-desktop \
  `# db clients` \
  mongodb-compass dbeaver-ce \
  `# redis/nats` \
  redisinsight-bin nats-server natscli \
  `# gaming` \
  prismlauncher protonup-qt \
  `# vpn` \
  mullvad-vpn-bin \
  `# devops` \
  openlens-bin minikube kubectl-bin \
  `# productivity` \
  1password gitbutler-bin linear-app spotify \
  `# dev tools` \
  yourkit blockbench-bin bruno-bin \
  `# flatpak` \
  flatpak \
  `# keyboard RGB` \
  openrgb
ok "AUR batch done."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 3 — config · services · file writes  (all backgrounded, run in parallel)
# ══════════════════════════════════════════════════════════════════════════════
section "Phase 3 — configuring (parallel)"

_jobs=()

# ── Fonts ─────────────────────────────────────────────────────────────────────
_cfg_fonts() {
  fc-cache -fv &>/dev/null
  ok "Fonts: cache refreshed."
}

# ── KDE defaults ──────────────────────────────────────────────────────────────
_cfg_kde() {
  kwriteconfig6 --file kdeglobals --group KDE     --key SingleClick false
  kwriteconfig6 --file kdeglobals --group General --key ColorScheme 'BreezeDark'
  kwriteconfig6 --file kdeglobals --group Icons   --key Theme 'Papirus-Dark'
  kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library 'org.kde.klassy'
  kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true
  kwriteconfig6 --file plasmashellrc --group PlasmaViews --key 'panelOpacity' 1
  kwriteconfig6 --file baloofilerc --group 'Basic Settings' --key Indexing-Enabled false
  kwriteconfig6 --file kwinrc --group Compositing --key Backend OpenGL
  kwriteconfig6 --file kwinrc --group Compositing --key GLTextureFilter 2
  kwriteconfig6 --file kwinrc --group Compositing --key LatencyControl 0
  balooctl6 disable 2>/dev/null || balooctl disable 2>/dev/null || true
  if command -v powerprofilesctl &>/dev/null; then
    powerprofilesctl set performance
  else
    sudo systemctl enable --now power-profiles-daemon
    powerprofilesctl set performance
  fi
  ok "KDE: defaults configured."
}

# ── VSCode settings ───────────────────────────────────────────────────────────
_cfg_vscode() {
  VSCODE_CFG="$HOME/.config/Code/User/settings.json"
  mkdir -p "$(dirname "$VSCODE_CFG")"
  cat > "$VSCODE_CFG" << 'VSJSON'
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
  "editor.fontSize": 13,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.tabSize": 4,
  "editor.insertSpaces": true,
  "editor.renderWhitespace": "selection",
  "editor.minimap.enabled": false,
  "editor.scrollbar.vertical": "hidden",
  "editor.scrollbar.horizontal": "hidden",
  "editor.overviewRulerBorder": false,
  "editor.hideCursorInOverviewRuler": true,
  "editor.glyphMargin": false,
  "editor.folding": false,
  "editor.lineNumbers": "relative",
  "editor.renderLineHighlight": "gutter",
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.suggest.preview": true,
  "editor.inlineSuggest.enabled": true,
  "workbench.colorTheme": "Default Dark Modern",
  "workbench.iconTheme": "vs-minimal",
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": true,
  "workbench.layoutControl.enabled": false,
  "workbench.editor.showTabs": "multiple",
  "workbench.editor.tabSizing": "shrink",
  "workbench.sideBar.location": "right",
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
  "workbench.tree.indent": 14,
  "window.titleBarStyle": "custom",
  "window.menuBarVisibility": "compact",
  "window.commandCenter": false,
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
  "terminal.integrated.fontSize": 12,
  "terminal.integrated.defaultProfile.linux": "fish",
  "breadcrumbs.enabled": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "none",
  "extensions.autoCheckUpdates": false,
  "git.autofetch": true,
  "git.confirmSync": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.autoSave": "onFocusChange",
  "[java]": { "editor.defaultFormatter": "redhat.java" },
  "[csharp]": { "editor.defaultFormatter": "ms-dotnettools.csharp" }
}
VSJSON
  ok "VSCode: minimal settings written."
}

# ── Docker ────────────────────────────────────────────────────────────────────
_cfg_docker() {
  sudo systemctl enable --now docker.service
  sudo usermod -aG docker "$USER"
  warn "Docker Desktop uses its own context: docker context use desktop-linux"
  warn "Back to Engine:                       docker context use default"
  ok "Docker: engine enabled."
}

# ── NATS systemd unit ─────────────────────────────────────────────────────────
_cfg_nats() {
  mkdir -p "$HOME/.config/systemd/user"
  cat > "$HOME/.config/systemd/user/nats-dev.service" << 'NATS'
[Unit]
Description=NATS dev server (local)
After=network.target

[Service]
ExecStart=/usr/bin/nats-server -p 4222 -m 8222 --jetstream
Restart=on-failure

[Install]
WantedBy=default.target
NATS
  systemctl --user daemon-reload
  systemctl --user enable --now nats-dev.service
  ok "NATS: dev server enabled (4222/8222)."
}

# ── Android ───────────────────────────────────────────────────────────────────
_cfg_android() {
  sudo usermod -aG adbusers "$USER" 2>/dev/null || true
  ok "Android: adb group set."
}

# ── Gaming ────────────────────────────────────────────────────────────────────
_cfg_gaming() {
  sudo usermod -aG gamemode "$USER"
  systemctl --user enable --now gamemoded.service 2>/dev/null || true
  ok "Gaming: GameMode enabled."
}

# ── VPN/net ───────────────────────────────────────────────────────────────────
_cfg_vpn() {
  sudo systemctl enable mullvad-daemon.service
  sudo systemctl enable tailscaled.service
  sudo usermod -aG wireshark "$USER"
  sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap 2>/dev/null || true
  ok "VPN: Mullvad + Tailscale enabled (start after login)."
}

# ── Minikube ──────────────────────────────────────────────────────────────────
_cfg_minikube() {
  minikube config set driver docker 2>/dev/null || true
  ok "Minikube: driver → docker."
}

# ── 1Password SSH agent ───────────────────────────────────────────────────────
_cfg_1password() {
  mkdir -p "$HOME/.config/fish/conf.d"
  cat > "$HOME/.config/fish/conf.d/1password-ssh.fish" << 'OP'
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
OP
  ok "1Password: SSH agent socket configured."
}

# ── OBS virtual camera ────────────────────────────────────────────────────────
_cfg_media() {
  echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
  sudo modprobe v4l2loopback 2>/dev/null || true
  kwriteconfig6 --file kglobalshortcutsrc \
    --group flameshot --key 'capture' 'Print,Print,Take screenshot'
  ok "Media: OBS virtual camera + Flameshot shortcut set."
}

# ── System tweaks ─────────────────────────────────────────────────────────────
_cfg_tweaks() {
  sudo reflector --protocol https --sort rate --latest 10 \
    --save /etc/pacman.d/mirrorlist 2>/dev/null
  ok "Tweaks: mirrors refreshed."

  sudo bash -c 'cat > /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'
  sudo systemctl daemon-reload
  sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
  ok "Tweaks: zram enabled."

  echo "vm.swappiness=10"            | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
  echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf &>/dev/null
  sudo sysctl -p /etc/sysctl.d/99-inotify.conf &>/dev/null
  ok "Tweaks: swappiness=10, inotify=524288."

  sudo systemctl enable --now fstrim.timer
  sudo systemctl enable --now irqbalance
  ok "Tweaks: fstrim + irqbalance enabled."
}

# ── Git global config ─────────────────────────────────────────────────────────
_cfg_git() {
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global core.autocrlf input
  git config --global push.autoSetupRemote true
  git config --global rerere.enabled true
  git config --global fetch.prune true
  ok "Git: global defaults set."
}

# ── Flatpak ───────────────────────────────────────────────────────────────────
_cfg_flatpak() {
  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
  ok "Flatpak: Flathub added."
}

# ── Font rendering ────────────────────────────────────────────────────────────
_cfg_fontrendering() {
  kwriteconfig6 --file kdeglobals \
    --group General --key font 'Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
  kwriteconfig6 --file kdeglobals \
    --group General --key fixed 'JetBrainsMono Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
  kwriteconfig6 --file kcmfonts --group General --key antiAliasing 1
  kwriteconfig6 --file kcmfonts --group General --key subPixelType rgb
  kwriteconfig6 --file kcmfonts --group General --key hintingStyle slight
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
  ok "Font rendering: subpixel LCD configured."
}

# ── Full power — no throttling, no sleep, max performance ────────────────────
_cfg_power() {
  # CPU — performance governor
  sudo cpupower frequency-set -g performance &>/dev/null || true
  # Persist across reboots
  sudo mkdir -p /etc/systemd/system/cpupower.service.d
  cat << 'EOF' | sudo tee /etc/systemd/system/cpupower.service.d/performance.conf >/dev/null
[Service]
ExecStart=
ExecStart=/usr/bin/cpupower frequency-set -g performance
EOF
  sudo systemctl enable cpupower.service 2>/dev/null || true

  # Power profile daemon → performance
  powerprofilesctl set performance 2>/dev/null || true

  # USB autosuspend — disable (stops peripherals dropping out)
  echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend &>/dev/null || true
  echo 'options usbcore autosuspend=-1' \
    | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null

  # KDE power management — never sleep, never dim, never lock on idle
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
powerDownAction=1

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

  # Screen locker — disable auto-lock
  kwriteconfig6 --file kscreenlockerrc \
    --group Daemon --key Autolock false
  kwriteconfig6 --file kscreenlockerrc \
    --group Daemon --key Timeout 0

  # Keyboard backlight — max brightness on login
  if command -v brightnessctl &>/dev/null; then
    # Try common keyboard backlight device paths
    for dev in /sys/class/leds/*kbd*; do
      [[ -d "$dev" ]] && brightnessctl --device="$(basename "$dev")" set 100% &>/dev/null || true
    done
    # Persist via udev rule
    cat << 'UDEV' | sudo tee /etc/udev/rules.d/90-kbd-backlight.rules >/dev/null
ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*kbd*", \
  RUN+="/usr/bin/brightnessctl --device=%k set 100%%"
UDEV
  fi

  # OpenRGB — enable udev rules for non-root access
  if command -v openrgb &>/dev/null; then
    sudo openrgb --startminimized 2>/dev/null || true
    # udev rules ship with openrgb — just reload
    sudo udevadm control --reload-rules 2>/dev/null || true
  fi

  ok "Power: CPU=performance, no sleep, no dim, keyboard backlight=max."
}
_cfg_bashrc() {
  cat >> "$HOME/.bashrc" << 'BASH'

jdk() {
  if [[ -z "${1:-}" ]]; then archlinux-java status; return; fi
  sudo archlinux-java set "java-${1}-openjdk"
  export JAVA_HOME="/usr/lib/jvm/java-${1}-openjdk"
  java -version
}
BASH
  ok "bashrc: jdk() switcher added."
}

# ── Launch all config jobs in parallel ────────────────────────────────────────
log "Spawning config jobs..."

_cfg_fonts         & _jobs+=($!)
_cfg_kde           & _jobs+=($!)
_cfg_vscode        & _jobs+=($!)
_cfg_docker        & _jobs+=($!)
_cfg_nats          & _jobs+=($!)
_cfg_android       & _jobs+=($!)
_cfg_gaming        & _jobs+=($!)
_cfg_vpn           & _jobs+=($!)
_cfg_minikube      & _jobs+=($!)
_cfg_1password     & _jobs+=($!)
_cfg_media         & _jobs+=($!)
_cfg_tweaks        & _jobs+=($!)
_cfg_git           & _jobs+=($!)
_cfg_flatpak       & _jobs+=($!)
_cfg_fontrendering & _jobs+=($!)
_cfg_bashrc        & _jobs+=($!)
_cfg_power         & _jobs+=($!)

log "Waiting for ${#_jobs[@]} config jobs..."
_failed=0
for pid in "${_jobs[@]}"; do
  wait "$pid" || (( _failed++ )) || true
done

if (( _failed > 0 )); then
  warn "$_failed config job(s) had errors — check output above."
else
  ok "Phase 3 done — all config jobs complete."
fi

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 4 — sequential post-install (depends on packages being present)
# ══════════════════════════════════════════════════════════════════════════════
section "Phase 4 — JDKs · Node · post-install"

# ── JDKs ─────────────────────────────────────────────────────────────────────
log "Discovering OpenJDK LTS packages..."
AVAILABLE_JDKS=$(pacman -Ssq '^jdk[0-9]+-openjdk$' 2>/dev/null || true)
if [[ -n "$AVAILABLE_JDKS" ]]; then
  log "Found: $(echo "$AVAILABLE_JDKS" | tr '\n' ' ')"
  # shellcheck disable=SC2086
  pacin $AVAILABLE_JDKS
else
  warn "JDK auto-discovery failed — falling back to known LTS list."
  pacin jdk8-openjdk jdk11-openjdk jdk17-openjdk jdk21-openjdk 2>/dev/null || true
fi

INSTALLED_VERSIONS=$(archlinux-java status 2>/dev/null | grep -oP 'java-\K[0-9]+' | sort -n || true)
HIGHEST=$(echo "$INSTALLED_VERSIONS" | tail -1)
if [[ -n "$HIGHEST" ]]; then
  NEXT=$(( HIGHEST + 4 ))
  aurin "jdk${NEXT}-openjdk" 2>/dev/null \
    && ok "jdk${NEXT}-openjdk installed from AUR." \
    || log "jdk${NEXT} not in AUR yet — you have the latest."
fi

LATEST_JDK=$(archlinux-java status 2>/dev/null \
  | grep -oP 'java-\K[0-9]+-openjdk' | sort -t- -k1 -n | tail -1)
if [[ -n "$LATEST_JDK" ]]; then
  sudo archlinux-java set "java-${LATEST_JDK}" 2>/dev/null || true
  ok "Default JDK → java-${LATEST_JDK}"
fi

# ── Node via fnm ─────────────────────────────────────────────────────────────
log "Installing Node LTS via fnm..."
export FNM_DIR="$HOME/.local/share/fnm"
export PATH="$FNM_DIR:$PATH"
eval "$(fnm env --shell bash 2>/dev/null)" || true
fnm install --lts
fnm default lts-latest 2>/dev/null || true
npm i -g typescript tsx pnpm prettier eslint 2>/dev/null \
  && ok "Node $(node -v 2>/dev/null) + globals installed." \
  || warn "npm globals failed — run after relogin: npm i -g typescript tsx pnpm prettier eslint"

ok "Phase 4 done."

# ══════════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════════
echo -e ""
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  Setup complete.${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e ""
echo -e "  ${C}After reboot:${D}"
echo -e "    ${Y}sudo tailscale up${D}         → connect Tailscale"
echo -e "    ${Y}protonup-qt${D}               → download Proton-GE"
echo -e "    ${Y}jetbrains-toolbox${D}          → install IDEs"
echo -e ""
echo -e "  ${C}JDK switching:${D}"
echo -e "    ${Y}jdk 8|11|17|21|25${D}         → switch default JVM"
echo -e "    ${Y}jdk${D}                       → list installed"
echo -e ""

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 5 — configuration wizard (interactive, always last)
# ══════════════════════════════════════════════════════════════════════════════
_wizard_ask() {
  printf "\n  ${Y}?${D} $1 [Y/n] "
  local r; read -r r; [[ "${r:-y}" =~ ^[Yy]$ ]]
}
_wizard_step() { echo -e "\n${W}  ─── $* ───${D}"; }

echo -e "${W}━━━  Configuration Wizard  ━━━${D}"
echo -e "  walks through things that need your input."
printf "\n  run it? [Y/n] "; read -r _RUN_WIZARD
if [[ "${_RUN_WIZARD:-y}" =~ ^[Yy]$ ]]; then

  _wizard_step "Git identity"
  if _wizard_ask "Set git name and email?"; then
    printf "  name:  "; read -r _GIT_NAME
    printf "  email: "; read -r _GIT_EMAIL
    git config --global user.name  "$_GIT_NAME"
    git config --global user.email "$_GIT_EMAIL"
    ok "Git: $_GIT_NAME <$_GIT_EMAIL>"
  fi

  _wizard_step "SSH key (ed25519)"
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    if _wizard_ask "Generate SSH key?"; then
      printf "  email for key: "; read -r _SSH_EMAIL
      _SSH_EMAIL="${_SSH_EMAIL:-${_GIT_EMAIL:-$(whoami)@$(hostname)}}"
      ssh-keygen -t ed25519 -C "$_SSH_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
      eval "$(ssh-agent -s)" &>/dev/null
      ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
      echo -e "\n  ${C}Public key — add to GitHub / GitLab:${D}"
      echo -e "  ${W}$(cat "$HOME/.ssh/id_ed25519.pub")${D}"
    fi
  else
    ok "SSH key exists at ~/.ssh/id_ed25519"
    echo -e "  ${W}$(cat "$HOME/.ssh/id_ed25519.pub")${D}"
  fi

  _wizard_step "GitHub CLI"
  if _wizard_ask "Authenticate gh? (opens browser)"; then
    gh auth login
  fi

  _wizard_step "Docker context"
  echo -e "  default  → Docker Engine"
  echo -e "  desktop  → Docker Desktop (separate VM)"
  if _wizard_ask "Switch to Docker Desktop context?"; then
    docker context use desktop-linux 2>/dev/null \
      && ok "Docker context → desktop-linux" \
      || warn "Desktop context not found — is Docker Desktop running?"
  else
    docker context use default 2>/dev/null || true
    ok "Docker context → default (Engine)"
  fi

  _wizard_step "Tailscale"
  if _wizard_ask "Connect Tailscale?"; then
    sudo tailscale up
  fi

  _wizard_step "Mullvad VPN"
  if _wizard_ask "Log in to Mullvad?"; then
    printf "  account number: "; read -r _MULLVAD_ACCT
    mullvad account login "$_MULLVAD_ACCT" \
      && ok "Mullvad logged in." \
      || warn "Login failed — run: mullvad account login <number>"
  fi

  _wizard_step "1Password SSH agent"
  if _wizard_ask "Enable 1Password SSH agent?"; then
    warn "Enable in 1Password → Settings → Developer → SSH Agent."
  fi

  _wizard_step "Default JDK"
  echo -e "  $(archlinux-java status 2>/dev/null || echo 'none found')"
  if _wizard_ask "Set a default JDK?"; then
    printf "  version (8/11/17/21/25): "; read -r _JDK_VER
    sudo archlinux-java set "java-${_JDK_VER}-openjdk" \
      && ok "Default JDK → $_JDK_VER" \
      || warn "Could not set — check: archlinux-java status"
  fi

  _wizard_step "Custom wallpaper"
  if _wizard_ask "Add a custom wallpaper to the rotation?"; then
    printf "  path to image: "; read -r _WALL_PATH
    _WALL_PATH="${_WALL_PATH/#\~/$HOME}"
    if [[ -f "$_WALL_PATH" ]]; then
      mkdir -p "$HOME/.local/share/wallpapers/rice"
      cp "$_WALL_PATH" "$HOME/.local/share/wallpapers/rice/$(basename "$_WALL_PATH")"
      ok "Wallpaper added to rotation."
    else
      warn "File not found: $_WALL_PATH"
    fi
  fi

  echo -e "\n${G}  ✔  Wizard complete.${D}\n"
fi

echo -e "  ${C}Reboot now:${D}  ${Y}sudo reboot${D}\n"