#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  setup.sh — CachyOS KDE game dev setup
#  idempotent: safe to run multiple times
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'
log()  { echo -e "${C}→${D} $*"; }
ok()   { echo -e "${G}✔${D} $*"; }
warn() { echo -e "${Y}⚠${D}  $*"; }
die()  { echo -e "${R}✖${D} $*" >&2; exit 1; }
h()    { echo -e "\n${W}━━━  $*  ━━━${D}"; }

pi() { sudo pacman -S --needed --noconfirm "$@" 2>&1 | grep -v 'up to date' || true; }

aur() {
  local pkg="$1"
  # pacman -Q not paru -Q — avoids paru initialization on every check
  pacman -Q "$pkg" &>/dev/null && return 0
  log "  $pkg"
  GIT_TERMINAL_PROMPT=0 PAGER=cat LESS= EDITOR=true BAT_PAGER=cat \
    timeout 300 paru -S --needed --noconfirm --nopgpfetch --skipreview \
    "$pkg" </dev/null &>/dev/null \
    && ok "  $pkg" \
    || warn "  $pkg — skipped"
}

svc_enable() {
  local bin="$1" svc="$2"
  if command -v "$bin" &>/dev/null; then
    sudo systemctl enable "$svc" 2>/dev/null && ok "  $svc" || true
  else
    warn "  $svc skipped ($bin not installed)"
  fi
}

[[ $EUID -eq 0 ]] && die "run as normal user"
command -v pacman &>/dev/null || die "pacman not found"

clear
echo -e "${W}"
cat << 'EOF'
  ╔══════════════════════════════════════╗
  ║  CachyOS KDE · Game Dev Setup       ║
  ╚══════════════════════════════════════╝
EOF
echo -e "${D}"

h "sudo · multilib · paru"

SUDOERS="/etc/sudoers.d/nopasswd-wheel"
if [[ ! -f "$SUDOERS" ]]; then
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS" >/dev/null
  sudo chmod 440 "$SUDOERS"
  ok "passwordless sudo → wheel"
fi

log "system upgrade..."
sudo pacman -Syu --noconfirm

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/{n;s/^#//};/^#\[multilib\]/s/^#//' /etc/pacman.conf
  sudo pacman -Sy --noconfirm
  ok "multilib enabled"
fi

if ! command -v paru &>/dev/null; then
  log "building paru..."
  pi git base-devel
  T=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$T/paru"
  pushd "$T/paru" >/dev/null; makepkg -si --noconfirm; popd >/dev/null
  rm -rf "$T"
  ok "paru installed"
fi

# write paru config — fully non-interactive
mkdir -p "$HOME/.config/paru"
cat > "$HOME/.config/paru/paru.conf" << 'PARU_CONF'
[options]
SkipReview
NewsOnUpgrade = false
RemoveMake
CleanAfter
PARU_CONF
ok "paru configured (non-interactive)"

h "pacman packages"

pi \
  fish starship zoxide fzf fd ripgrep bat eza tmux \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-liberation ttf-dejavu otf-font-awesome \
  kvantum qt5ct qt6ct \
  discord signal-desktop \
  git python python-pip python-virtualenv github-cli \
  docker docker-compose docker-buildx \
  sqlitebrowser \
  android-tools android-udev scrcpy gvfs-mtp \
  steam gamemode lib32-gamemode mangohud lib32-mangohud \
  wireguard-tools tailscale wireshark-qt \
  thunderbird \
  obs-studio audacity v4l2loopback-dkms flameshot \
  reflector zram-generator irqbalance cpupower brightnessctl \
  power-profiles-daemon imagemagick
ok "pacman done"

h "AUR packages"

# write paru config to be fully non-interactive
mkdir -p "$HOME/.config/paru"
cat > "$HOME/.config/paru/paru.conf" << 'PCONF'
[options]
SkipReview
NewsOnUpgrade = false
RemoveMake
CleanAfter
PCONF

# release any pacman db lock left from the -Syu above
sudo rm -f /var/lib/pacman/db.lck 2>/dev/null || true

aur ttf-ms-win11-auto
aur catppuccin-kde-git
aur papirus-icon-theme
aur bibata-cursor-theme
aur klassy-bin
aur vivaldi
aur vivaldi-ffmpeg-codecs
aur librewolf-bin
aur ungoogled-chromium-bin
aur tor-browser
aur discord-canary
aur slack-desktop
aur rocketchat-desktop
aur zed
aur visual-studio-code-bin
aur jetbrains-toolbox
aur fnm-bin
aur bun-bin
aur docker-desktop
aur mongodb-compass
aur dbeaver-ce
aur redisinsight-bin
aur nats-server
aur natscli
aur prismlauncher
aur protonup-qt
aur mullvad-vpn-bin
aur openlens-bin
aur minikube
aur kubectl-bin
aur 1password
aur gitbutler-bin
aur linear-app
aur spotify
aur yourkit
aur blockbench-bin
aur bruno-bin
aur flatpak
aur openrgb
ok "AUR done"

h "shell — fish · starship · ghostty"

FISH_BIN="$(command -v fish)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$FISH_BIN" ]]; then
  sudo usermod -s "$FISH_BIN" "$USER"
  ok "default shell → fish"
fi

mkdir -p "$HOME/.config/fish/conf.d"

cat > "$HOME/.config/fish/config.fish" << 'FISH'
starship init fish | source
zoxide init fish | source

alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

function jdk
    if test -z "$argv[1]"
        archlinux-java status; return
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
style = "bold cyan"
truncation_length = 3
truncate_to_repo = true

[git_branch]
format = " [on](dim white) [$symbol$branch](bold purple)"
symbol = " "

[git_status]
format = "([$all_status$ahead_behind]($style) )"
style = "bold yellow"
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
modified = "!${count}"
untracked = "?${count}"
staged = "+${count}"

[java]
format = " [☕ $version](bold red)"
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
disabled = false
format = "[$time](dim white) "
time_format = "%H:%M"
STAR

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

cat > "$HOME/.config/ghostty/config" << 'GHOSTTY'
theme                  = rose-pine
font-family            = JetBrainsMono Nerd Font
font-size              = 13
font-thicken           = true
window-padding-x       = 12
window-padding-y       = 8
background-opacity     = 0.97
background-blur-radius = 20
shell-integration      = fish
scrollback-limit       = 10000
copy-on-select         = clipboard
cursor-style           = bar
cursor-style-blink     = true
gtk-tabs-location      = bottom
gtk-wide-tabs          = false
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
ok "shell configured"

h "VSCode"

mkdir -p "$HOME/.config/Code/User"
cat > "$HOME/.config/Code/User/settings.json" << 'JSON'
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
  "editor.fontSize": 13,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.tabSize": 4,
  "editor.minimap.enabled": false,
  "editor.scrollbar.vertical": "hidden",
  "editor.scrollbar.horizontal": "hidden",
  "editor.overviewRulerBorder": false,
  "editor.glyphMargin": false,
  "editor.lineNumbers": "relative",
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "workbench.colorTheme": "Default Dark Modern",
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": true,
  "workbench.layoutControl.enabled": false,
  "workbench.sideBar.location": "right",
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
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
  "files.autoSave": "onFocusChange"
}
JSON
ok "VSCode configured"

h "git defaults"

git config --global init.defaultBranch   main
git config --global pull.rebase          false
git config --global core.autocrlf        input
git config --global push.autoSetupRemote true
git config --global rerere.enabled       true
git config --global fetch.prune          true

if ! grep -q '__jdk_switcher__' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" << 'BASH'
# __jdk_switcher__
jdk() {
  if [[ -z "${1:-}" ]]; then archlinux-java status; return; fi
  sudo archlinux-java set "java-${1}-openjdk"
  export JAVA_HOME="/usr/lib/jvm/java-${1}-openjdk"
  java -version
}
BASH
fi
ok "git + jdk() configured"

h "services"

sudo systemctl enable docker.service docker.socket
sudo usermod -aG docker "$USER"
ok "docker enabled"

sudo usermod -aG gamemode "$USER"
systemctl --user enable --now gamemoded.service 2>/dev/null || true
ok "gamemode enabled"

sudo usermod -aG adbusers "$USER" 2>/dev/null || true
ok "adb group set"

svc_enable mullvad   mullvad-daemon.service
svc_enable tailscale tailscaled.service
sudo usermod -aG wireshark "$USER"
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap 2>/dev/null || true
ok "VPN daemons enabled"

command -v flatpak &>/dev/null && \
  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null
ok "flatpak: flathub added"

echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
sudo modprobe v4l2loopback 2>/dev/null || true
ok "OBS virtual camera module loaded"

if command -v minikube &>/dev/null; then
  minikube config set driver docker 2>/dev/null
  ok "minikube driver → docker"
fi

if command -v nats-server &>/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  cat > "$HOME/.config/systemd/user/nats-dev.service" << 'NATS'
[Unit]
Description=NATS dev server
After=network.target

[Service]
ExecStart=/usr/bin/nats-server -p 4222 -m 8222 --jetstream
Restart=on-failure

[Install]
WantedBy=default.target
NATS
  systemctl --user daemon-reload
  systemctl --user enable --now nats-dev.service
  ok "NATS enabled (4222/8222)"
fi

cat > "$HOME/.config/fish/conf.d/1password-ssh.fish" << 'OP'
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
OP

h "system tweaks"

log "refreshing mirrors..."
sudo reflector --protocol https --sort rate --latest 10 \
  --save /etc/pacman.d/mirrorlist 2>/dev/null && ok "mirrors refreshed"

if [[ ! -f /etc/systemd/zram-generator.conf ]]; then
  sudo bash -c 'cat > /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'
  sudo systemctl daemon-reload
  sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
  ok "zram enabled"
fi

sudo tee /etc/sysctl.d/99-perf.conf >/dev/null << 'SYSCTL'
vm.swappiness=10
fs.inotify.max_user_watches=524288
SYSCTL
sudo sysctl --system &>/dev/null
ok "sysctl applied"

sudo systemctl enable --now fstrim.timer irqbalance

powerprofilesctl set performance 2>/dev/null || true
sudo cpupower frequency-set -g performance &>/dev/null || true
sudo mkdir -p /etc/systemd/system/cpupower.service.d
sudo tee /etc/systemd/system/cpupower.service.d/performance.conf >/dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/cpupower frequency-set -g performance
EOF
sudo systemctl enable cpupower.service 2>/dev/null || true

echo 'options usbcore autosuspend=-1' | \
  sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf >/dev/null

kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 0

for dev in /sys/class/leds/*kbd*; do
  [[ -d "$dev" ]] && brightnessctl --device="$(basename "$dev")" set 100% &>/dev/null || true
done
command -v brightnessctl &>/dev/null && sudo tee /etc/udev/rules.d/90-kbd-backlight.rules >/dev/null << 'UDEV'
ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*kbd*", RUN+="/usr/bin/brightnessctl --device=%k set 100%%"
UDEV

sudo tee "$HOME/.config/powermanagementprofilesrc" >/dev/null << 'POWER'
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

[Battery][SuspendSession]
idleTime=0
suspendType=0

[LowBattery][SuspendSession]
idleTime=0
suspendType=0
POWER

fc-cache -fv &>/dev/null
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
ok "tweaks applied"

h "JDKs"

mapfile -t JDKS < <(pacman -Ssq '^jdk[0-9]+-openjdk$' 2>/dev/null | sort -V | uniq)
if [[ ${#JDKS[@]} -gt 0 ]]; then
  log "found: ${JDKS[*]}"
  pi "${JDKS[@]}"
else
  warn "auto-discovery failed — installing known LTS list"
  pi jdk8-openjdk jdk11-openjdk jdk17-openjdk jdk21-openjdk 2>/dev/null || true
fi

HIGHEST=$(archlinux-java status 2>/dev/null \
  | grep -oP 'java-\K[0-9]+(?=-openjdk)' | sort -n | uniq | tail -1 || true)
if [[ -n "$HIGHEST" ]]; then
  NEXT=$(( HIGHEST + 4 ))
  if ! pacman -Q "jdk${NEXT}-openjdk" &>/dev/null; then
    paru -S --needed --noconfirm "jdk${NEXT}-openjdk" &>/dev/null \
      && ok "jdk${NEXT} installed from AUR" \
      || log "jdk${NEXT} not in AUR yet"
  fi
fi

LATEST=$(archlinux-java status 2>/dev/null \
  | grep -oP 'java-\K[0-9]+-openjdk' | sort -t- -k1 -n | tail -1 || true)
[[ -n "$LATEST" ]] && sudo archlinux-java set "java-${LATEST}" 2>/dev/null \
  && ok "default JDK → java-${LATEST}"

h "Node (fnm)"

if command -v fnm &>/dev/null; then
  export FNM_DIR="$HOME/.local/share/fnm"
  export PATH="$FNM_DIR:$PATH"
  eval "$(fnm env --shell bash 2>/dev/null)" || true
  fnm install --lts 2>/dev/null || true
  fnm default lts-latest 2>/dev/null || true
  if command -v npm &>/dev/null; then
    npm i -g typescript tsx pnpm prettier eslint 2>/dev/null \
      && ok "Node $(node -v) + globals" \
      || warn "npm globals: run after relogin"
  fi
fi

echo -e "\n${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  setup complete${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}\n"
echo -e "  next: run ${Y}bash rice.sh${D} from a KDE session"
echo -e "  then: ${Y}sudo reboot${D}\n"

h "configuration wizard"

_ask() { printf "\n  ${Y}?${D} $1 [Y/n] "; local r; read -r r; [[ "${r:-y}" =~ ^[Yy]$ ]]; }
_step() { echo -e "\n${W}  ─── $* ───${D}"; }

printf "\n  run wizard? [Y/n] "; read -r _W
[[ "${_W:-y}" =~ ^[Yy]$ ]] || { echo -e "  ${Y}run rice.sh when ready${D}\n"; exit 0; }

_step "git identity"
if _ask "set git name + email?"; then
  printf "  name:  "; read -r _N
  printf "  email: "; read -r _E
  git config --global user.name  "$_N"
  git config --global user.email "$_E"
  ok "git: $_N <$_E>"
fi

_step "SSH key"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  if _ask "generate SSH key?"; then
    printf "  email: "; read -r _SE
    _SE="${_SE:-$(whoami)@$(hostname)}"
    ssh-keygen -t ed25519 -C "$_SE" -f "$HOME/.ssh/id_ed25519" -N ""
    eval "$(ssh-agent -s)" &>/dev/null; ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
    echo -e "\n  ${C}public key:${D}\n  ${W}$(cat "$HOME/.ssh/id_ed25519.pub")${D}"
  fi
else
  ok "SSH key exists: $(cat "$HOME/.ssh/id_ed25519.pub")"
fi

_step "GitHub CLI"
_ask "gh auth login?" && gh auth login

_step "Docker context"
if _ask "use Docker Desktop context?"; then
  docker context use desktop-linux 2>/dev/null && ok "context → desktop-linux" \
    || warn "context not found — start Docker Desktop first"
else
  docker context use default 2>/dev/null || true
  ok "context → default (engine)"
fi

_step "Tailscale"
_ask "connect tailscale?" && sudo tailscale up

_step "Mullvad"
if _ask "log in to Mullvad?"; then
  printf "  account number: "; read -r _MA
  mullvad account login "$_MA" && ok "Mullvad logged in" \
    || warn "failed — run: mullvad account login <number>"
fi

_step "default JDK"
echo "  $(archlinux-java status 2>/dev/null || echo 'none')"
if _ask "set default JDK?"; then
  printf "  version (8/11/17/21/25): "; read -r _JV
  sudo archlinux-java set "java-${_JV}-openjdk" && ok "JDK → $_JV" \
    || warn "not found — check: archlinux-java status"
fi

_step "wallpaper"
if _ask "add a wallpaper to the rotation?"; then
  printf "  path: "; read -r _WP
  _WP="${_WP/#\~/$HOME}"
  if [[ -f "$_WP" ]]; then
    mkdir -p "$HOME/.local/share/wallpapers/rice"
    cp "$_WP" "$HOME/.local/share/wallpapers/rice/$(basename "$_WP")"
    ok "added to rotation"
  else
    warn "not found: $_WP"
  fi
fi

echo -e "\n${G}  ✔  wizard done — run rice.sh next${D}\n"