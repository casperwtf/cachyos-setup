#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  CachyOS KDE — Game Dev Setup
#  Aesthetic: sharp minimal dark, Windows-comfortable
#  Scope: Game dev (Java/C#/general), full browser suite, comms, DevOps, gaming
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail
IFS=$'\n\t'

# ── Colour palette ────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
B='\033[0;34m' C='\033[0;36m' W='\033[1;37m' D='\033[0m'

# ── Primitives ────────────────────────────────────────────────────────────────
log()  { echo -e "${C}→${D} $*"; }
ok()   { echo -e "${G}✔${D} $*"; }
warn() { echo -e "${Y}⚠${D}  $*"; }
die()  { echo -e "${R}✖ ${D}$*" >&2; exit 1; }
skip() { echo -e "${W}–${D} skip: $*"; }

section() {
  echo -e "\n${W}━━━  $*  ━━━${D}"
  return 0
}

ask() { return 0; }   # always yes — script runs unattended

pacin()  { sudo pacman -S --needed --noconfirm "$@" 2>/dev/null; }
aurin()  { paru  -S --needed --noconfirm "$@" 2>/dev/null || warn "AUR miss: $*"; }
flatin() { flatpak install -y flathub "$@" 2>/dev/null || warn "Flatpak miss: $*"; }

# ── Sanity ────────────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]]            && die "Run as your normal user, not root."
command -v pacman &>/dev/null || die "pacman not found — Arch-based system required."

# ══════════════════════════════════════════════════════════════════════════════
clear
echo -e "${W}"
cat << 'BANNER'
  ╔═══════════════════════════════════════════════╗
  ║     CachyOS KDE  ·  Game Dev Setup            ║
  ║     Java · C# · Node · Python · DevOps        ║
  ╚═══════════════════════════════════════════════╝
BANNER
echo -e "${D}"
echo -e "  ${C}Interactive — each section asks before running.${D}\n"
echo -e "  ${C}Running unattended — git identity skipped, set manually after.${D}\n"

# ══════════════════════════════════════════════════════════════════════════════
# passwordless sudo — system-wide for the wheel group
# ══════════════════════════════════════════════════════════════════════════════
SUDOERS_FILE="/etc/sudoers.d/nopasswd-wheel"
if [[ ! -f "$SUDOERS_FILE" ]]; then
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" >/dev/null
  sudo chmod 440 "$SUDOERS_FILE"
  ok "Passwordless sudo enabled for wheel group."
else
  ok "Passwordless sudo already set."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 0. SYSTEM UPDATE + MULTILIB + AUR HELPER
# ══════════════════════════════════════════════════════════════════════════════
if section "System update + multilib + paru"; then
  log "Full system upgrade..."
  sudo pacman -Syu --noconfirm

  if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    log "Enabling multilib..."
    sudo sed -i '/^#\[multilib\]/{n;s/^#//};/^#\[multilib\]/s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
  fi
  ok "System current."

  if ! command -v paru &>/dev/null; then
    log "Building paru..."
    pacin git base-devel
    T=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$T/paru"
    pushd "$T/paru" >/dev/null; makepkg -si --noconfirm; popd >/dev/null
    rm -rf "$T"
  fi
  ok "paru ready."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 1. TERMINAL — WezTerm + Fish + Starship
# ══════════════════════════════════════════════════════════════════════════════
if section "Terminal: WezTerm · Fish · Starship"; then
  pacin wezterm fish starship \
        zoxide fzf fd ripgrep bat eza tmux

  # ── Fish default shell ────────────────────────────────────────────────────
  if ask "Set fish as default shell?"; then
    chsh -s "$(command -v fish)"
    ok "Default shell → fish (takes effect on next login)."
  fi

  # ── Fish config ───────────────────────────────────────────────────────────
  FISH_CFG="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CFG")"
  cat > "$FISH_CFG" << 'FISH'
# ── Starship prompt ───────────────────────────────────────────────────────────
starship init fish | source

# ── zoxide (smart cd) ────────────────────────────────────────────────────────
zoxide init fish | source

# ── Aliases ──────────────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

# ── Java switcher  (usage: jdk 17) ───────────────────────────────────────────
function jdk
    if test -z "$argv[1]"
        echo "Installed JDKs:"
        archlinux-java status
        return
    end
    sudo archlinux-java set "java-$argv[1]-openjdk"
    set -gx JAVA_HOME (archlinux-java get | xargs -I{} /usr/lib/jvm/{}/bin/java -XshowSettings:all -version 2>&1 \
        | grep java.home | awk '{print $3}')
    echo "Java → $(java -version 2>&1 | head -1)"
end

# ── Node version helper (uses fnm) ───────────────────────────────────────────
if command -q fnm
    fnm env --use-on-cd | source
end

# ── PATH extras ──────────────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
FISH
  ok "Fish config written."

  # ── Starship config ───────────────────────────────────────────────────────
  STAR_CFG="$HOME/.config/starship.toml"
  cat > "$STAR_CFG" << 'STAR'
format = """
$directory$git_branch$git_status$java$kotlin$nodejs$python$rust$docker_context$line_break$character"""

add_newline = true

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"

[directory]
style            = "bold cyan"
truncation_length = 3
truncate_to_repo  = true

[git_branch]
format = " [on](dim white) [$symbol$branch](bold purple)"
symbol = " "

[git_status]
format    = "([$all_status$ahead_behind]($style) )"
style     = "bold yellow"
conflicted = "⚡"
ahead      = "⇡${count}"
behind     = "⇣${count}"
modified   = "!${count}"
untracked  = "?${count}"
staged     = "+${count}"

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
format   = "[$time](dim white) "
time_format = "%H:%M"
STAR
  ok "Starship config written."

  # ── WezTerm config ────────────────────────────────────────────────────────
  WEZTERM_DIR="$HOME/.config/wezterm"
  mkdir -p "$WEZTERM_DIR"
  cat > "$WEZTERM_DIR/wezterm.lua" << 'WEZ'
local wezterm = require 'wezterm'
local act     = wezterm.action
local config  = wezterm.config_builder()

-- Appearance
config.color_scheme           = 'Catppuccin Mocha'
config.font                   = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size              = 12.5
config.line_height            = 1.1
config.freetype_load_target   = 'HorizontalLcd'

-- Window chrome — minimal
config.window_decorations     = 'RESIZE'          -- no title bar, just border
config.window_background_opacity = 0.97
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar      = false
config.tab_bar_at_bottom      = true
config.tab_max_width          = 32
config.window_padding         = { left = 12, right = 12, top = 8, bottom = 0 }

-- Behaviour
config.scrollback_lines       = 10000
config.enable_scroll_bar      = false
config.audible_bell           = 'Disabled'
config.default_prog           = { '/usr/bin/fish' }

-- Colours (override tab bar to match)
config.colors = {
  tab_bar = {
    background        = '#1e1e2e',
    active_tab        = { bg_color = '#313244', fg_color = '#cdd6f4' },
    inactive_tab      = { bg_color = '#1e1e2e', fg_color = '#585b70' },
    inactive_tab_hover = { bg_color = '#313244', fg_color = '#cdd6f4' },
    new_tab           = { bg_color = '#1e1e2e', fg_color = '#585b70' },
    new_tab_hover     = { bg_color = '#313244', fg_color = '#cdd6f4' },
  },
}

-- Keybinds (Windows-Terminal-familiar)
config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = false } },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseSensitiveString = '' } },
  { key = '+', mods = 'CTRL',       action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL',       action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL',       action = act.ResetFontSize },
  -- Split panes
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
}

config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Right' } },
    mods  = 'NONE', action = act.PasteFrom 'PrimarySelection' },
}

return config
WEZ
  ok "WezTerm config written."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 2. FONTS
# ══════════════════════════════════════════════════════════════════════════════
if section "Fonts"; then
  pacin ttf-jetbrains-mono-nerd \
        noto-fonts noto-fonts-cjk noto-fonts-emoji \
        ttf-liberation ttf-dejavu \
        otf-font-awesome
  # Windows-compat fonts (useful when opening docs from Windows colleagues)
  aurin ttf-ms-win11-auto 2>/dev/null || \
    aurin ttf-windows 2>/dev/null || \
    warn "Windows font pack unavailable — install manually if needed."
  fc-cache -fv &>/dev/null
  ok "Fonts installed and cache refreshed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 3. KDE DEFAULTS — Windows-comfortable, clean dark
# ══════════════════════════════════════════════════════════════════════════════
if section "KDE defaults (dark · Windows-style · minimal)"; then
  pacin kvantum qt5ct qt6ct
  aurin  catppuccin-kde-git papirus-icon-theme bibata-cursor-theme \
         klassy                          # Clean window decorations
  # ── Core look ──────────────────────────────────────────────────────────────
  kwriteconfig6 --file kdeglobals \
    --group KDE      --key SingleClick false          # double-click (Windows habit)
  kwriteconfig6 --file kdeglobals \
    --group General  --key ColorScheme 'BreezeDark'
  kwriteconfig6 --file kdeglobals \
    --group Icons    --key Theme 'Papirus-Dark'
  kwriteconfig6 --file kwinrc \
    --group org.kde.kdecoration2 --key library 'org.kde.klassy'
  kwriteconfig6 --file kwinrc \
    --group Windows  --key BorderlessMaximizedWindows true

  # ── Taskbar behaviour (Windows-like) ───────────────────────────────────────
  kwriteconfig6 --file plasmashellrc \
    --group PlasmaViews --key 'panelOpacity' 1        # opaque taskbar

  # ── Disable Baloo (file indexer — kills performance) ───────────────────────
  balooctl6 disable 2>/dev/null || balooctl disable 2>/dev/null || true
  kwriteconfig6 --file baloofilerc \
    --group 'Basic Settings' --key Indexing-Enabled false

  # ── Compositor — performance over prettiness ───────────────────────────────
  kwriteconfig6 --file kwinrc \
    --group Compositing --key Backend OpenGL
  kwriteconfig6 --file kwinrc \
    --group Compositing --key GLTextureFilter 2       # bilinear — fast
  kwriteconfig6 --file kwinrc \
    --group Compositing --key LatencyControl 0        # lower input lag

  # ── Power profile — always on charger, set performance ─────────────────────
  if command -v powerprofilesctl &>/dev/null; then
    powerprofilesctl set performance
    ok "Power profile → performance."
  else
    pacin power-profiles-daemon
    sudo systemctl enable --now power-profiles-daemon
    powerprofilesctl set performance
    ok "power-profiles-daemon installed, profile → performance."
  fi

  ok "KDE configured. Changes visible after re-login."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 4. BROWSERS
# ══════════════════════════════════════════════════════════════════════════════
if section "Browsers: Vivaldi · LibreWolf · Chromium · Ungoogled · Tor"; then
  pacin chromium
  aurin vivaldi vivaldi-ffmpeg-codecs \
        librewolf-bin \
        ungoogled-chromium-bin \
        tor-browser
  ok "Browsers installed."
  warn "Vivaldi: install ffmpeg codecs via Vivaldi's built-in installer on first launch."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 5. COMMUNICATION
# ══════════════════════════════════════════════════════════════════════════════
if section "Comms: Discord · Discord Canary · Slack · Rocket.Chat · Signal"; then
  pacin discord signal-desktop
  aurin discord-canary \
        slack-desktop \
        rocketchat-desktop
  ok "Communication apps installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 6. EDITORS & IDEs
# ══════════════════════════════════════════════════════════════════════════════
if section "Editors: Zed · VSCode (minimal) · JetBrains Toolbox"; then

  # ── Zed ────────────────────────────────────────────────────────────────────
  aurin zed
  ok "Zed installed."

  # ── VSCode — install then strip it down ────────────────────────────────────
  aurin visual-studio-code-bin
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
  ok "VSCode installed with minimal settings."

  # ── JetBrains Toolbox (manages IntelliJ, Rider, PyCharm, WebStorm) ─────────
  aurin jetbrains-toolbox
  ok "JetBrains Toolbox installed. Launch it to install IntelliJ, Rider, PyCharm, WebStorm."
  warn "Toolbox apps install to ~/.local/share/JetBrains/Toolbox/apps/"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 7. JDKs — all LTS since 8 + switcher
# ══════════════════════════════════════════════════════════════════════════════
if section "JDKs: 8 · 11 · 17 · 21 · 25 + jdk() switcher"; then
  # ── Install LTS JDKs ───────────────────────────────────────────────────────
  # JDK 8, 11, 17 come from extra/community; 21 from extra; 25 may need AUR
  pacin jdk8-openjdk jdk11-openjdk jdk17-openjdk jdk21-openjdk || true
  # JDK 25 (latest LTS, September 2025)
  aurin jdk25-openjdk 2>/dev/null || \
    pacin jdk-openjdk 2>/dev/null || \
    warn "JDK 25 not found — install manually or via SDKMAN."

  # ── Default to JDK 21 ─────────────────────────────────────────────────────
  sudo archlinux-java set java-21-openjdk 2>/dev/null || true
  ok "Default JDK set to 21."

  # ── Fish jdk() function already in config.fish (see section 1) ───────────
  # Quick shortcut aliases in ~/.bashrc for bash fallback
  cat >> "$HOME/.bashrc" << 'BASH'

# ── JDK switcher ─────────────────────────────────────────────────────────────
jdk() {
  if [[ -z "$1" ]]; then
    archlinux-java status; return
  fi
  sudo archlinux-java set "java-${1}-openjdk"
  export JAVA_HOME="/usr/lib/jvm/java-${1}-openjdk"
  java -version
}
# Aliases for common switches
alias jdk8='jdk 8'  alias jdk11='jdk 11'
alias jdk17='jdk 17' alias jdk21='jdk 21' alias jdk25='jdk 25'
BASH

  log "Usage: jdk 17        — switch to JDK 17"
  log "       jdk            — list installed JDKs"
  log "       archlinux-java status  — same list"
  ok "JDK setup complete."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 8. DEV RUNTIME — Node · Bun · TypeScript · Python · Git
# ══════════════════════════════════════════════════════════════════════════════
if section "Dev runtime: Node (fnm) · Bun · TypeScript · Python · Git"; then
  pacin git python python-pip python-virtualenv

  # fnm — fast Node version manager (already initialised in config.fish)
  aurin fnm-bin
  log "Run 'fnm install --lts' after first login to install Node LTS."

  # Bun
  aurin bun-bin
  ok "Bun installed."

  # TypeScript + common global tools
  # (installed globally after Node is set up via fnm — can't do it now)
  cat >> "$HOME/.config/fish/config.fish" << 'POSTNPM'

# ── Global npm tools (installed after fnm sets up Node) ──────────────────────
# Run this once: npm i -g typescript tsx pnpm prettier eslint
POSTNPM

  # Git global defaults — set identity manually: git config --global user.name / user.email
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global core.autocrlf input
  git config --global push.autoSetupRemote true
  git config --global rerere.enabled true
  git config --global fetch.prune true
  warn "Git identity not set — run after install:"
  warn "  git config --global user.name  'Your Name'"
  warn "  git config --global user.email 'you@example.com'"

  # GitHub CLI — installed, auth done manually with: gh auth login
  pacin github-cli

  ok "Dev runtimes installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 9. DOCKER — Engine + Compose + Docker Desktop
# ══════════════════════════════════════════════════════════════════════════════
if section "Docker: Engine · Compose · Docker Desktop"; then
  pacin docker docker-compose docker-buildx

  # Docker Desktop (GUI — runs its own containerd context separate from Engine)
  if ask "  Install Docker Desktop (GUI)?"; then
    aurin docker-desktop
    warn "Docker Desktop requires KVM — ensure virtualization is enabled in BIOS."
    warn "Docker Desktop uses its own context. To switch: docker context use desktop-linux"
    warn "To switch back to Engine:               docker context use default"
  fi

  sudo systemctl enable --now docker.service
  sudo usermod -aG docker "$USER"
  ok "Docker Engine enabled. Re-login for group membership."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 10. DATABASE CLIENTS
# ══════════════════════════════════════════════════════════════════════════════
if section "DB clients: MongoDB Compass · DBeaver · DB Browser (SQLite)"; then
  # MongoDB Compass — official GUI
  aurin mongodb-compass
  # DBeaver Community — universal SQL client (Postgres, MySQL, MariaDB, MSSQL…)
  aurin dbeaver-ce
  # DB Browser for SQLite
  pacin sqlitebrowser
  ok "Database clients installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 11. REDIS GUI + NATS
# ══════════════════════════════════════════════════════════════════════════════
if section "Redis: RedisInsight GUI · NATS server + CLI"; then
  # RedisInsight — official Redis GUI
  aurin redisinsight-bin
  # NATS server + CLI
  aurin nats-server natscli
  # Quick systemd unit for local NATS dev server
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
  if ask "  Enable local NATS server at login?"; then
    systemctl --user enable --now nats-dev.service
    ok "NATS dev server enabled (port 4222 / monitor 8222)."
  fi
  ok "RedisInsight + NATS installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 12. ANDROID — adb · scrcpy · MTP
# ══════════════════════════════════════════════════════════════════════════════
if section "Android: adb · scrcpy (screen mirror) · MTP file transfer"; then
  pacin android-tools android-udev scrcpy gvfs-mtp
  # udev rules so device appears without root
  sudo systemctl restart udev || true
  sudo usermod -aG adbusers "$USER" 2>/dev/null || true
  ok "Android tools installed."
  log "Plug in device → enable USB Debugging → run: adb devices"
  log "Screen mirror:    scrcpy"
  log "File transfer:    plug in, set Android to 'File Transfer', open Dolphin"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 13. GAMING — Steam + Prism Launcher
# ══════════════════════════════════════════════════════════════════════════════
if section "Gaming: Steam (full) · Prism Launcher (Minecraft)"; then
  pacin steam \
        gamemode lib32-gamemode \
        mangohud lib32-mangohud

  aurin prismlauncher            # Minecraft / mod-loader launcher
  aurin protonup-qt              # Install Proton-GE builds

  sudo usermod -aG gamemode "$USER"
  systemctl --user enable --now gamemoded.service || true

  ok "Steam + Prism Launcher installed."
  log "Steam: Settings → Compatibility → Enable Steam Play for all titles"
  log "Launch ProtonUp-Qt to download Proton-GE builds."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 14. VPN & NETWORKING — Mullvad · Tailscale · WireGuard · Wireshark
# ══════════════════════════════════════════════════════════════════════════════
if section "VPN + Network: Mullvad · Tailscale · WireGuard · Wireshark"; then
  pacin wireguard-tools tailscale wireshark-qt

  aurin mullvad-vpn-bin

  sudo systemctl enable --now mullvad-daemon.service
  sudo systemctl enable --now tailscaled.service

  # Wireshark — allow non-root capture
  sudo usermod -aG wireshark "$USER"
  sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap 2>/dev/null || true

  ok "VPN + network tools installed."
  log "Mullvad: launch the app and log in with your account number."
  log "Tailscale: run  sudo tailscale up  to authenticate."
  warn "Re-login for wireshark group to take effect."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 15. DEVOPS — Lens · Minikube
# ══════════════════════════════════════════════════════════════════════════════
if section "DevOps: Lens (k8s IDE) · Minikube"; then
  aurin openlens-bin minikube
  # kubectl is needed by both
  pacin kubectl

  # Enable minikube with Docker driver (no VMs needed)
  if ask "  Set minikube default driver to docker?"; then
    minikube config set driver docker
    ok "minikube driver → docker."
  fi
  ok "Lens + Minikube installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 16. PRODUCTIVITY — Thunderbird · 1Password · Linear · GitButler · Spotify
# ══════════════════════════════════════════════════════════════════════════════
if section "Productivity: Thunderbird · 1Password · Linear · GitButler · Spotify"; then
  pacin thunderbird
  aurin 1password \
        gitbutler-bin \
        linear-app \
        spotify

  # 1Password SSH agent integration
  if ask "  Enable 1Password SSH agent integration?"; then
    mkdir -p "$HOME/.config/1Password/ssh"
    cat > "$HOME/.config/fish/conf.d/1password-ssh.fish" << 'OP'
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
OP
    ok "1Password SSH agent configured. Enable it in 1Password → Settings → Developer."
  fi

  ok "Productivity apps installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 17. DEV TOOLS — YourKit · Blockbench · Bruno · GitButler already above
# ══════════════════════════════════════════════════════════════════════════════
if section "Dev tools: YourKit · Blockbench · Bruno (HTTP)"; then
  # YourKit Java Profiler
  if ask "  Install YourKit Java Profiler (AUR)?"; then
    aurin yourkit
    ok "YourKit installed. Requires a valid license to activate."
  fi

  # Blockbench — 3D model editor (great for game assets/Minecraft)
  aurin blockbench-bin
  ok "Blockbench installed."

  # Bruno — offline HTTP client (Postman alternative, Git-friendly)
  aurin bruno-bin
  ok "Bruno installed."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 18. MEDIA — OBS · ShareX note · Audacity
# ══════════════════════════════════════════════════════════════════════════════
if section "Media: OBS · Audacity · Screenshot tools"; then
  pacin obs-studio audacity

  # Virtual camera for OBS
  pacin v4l2loopback-dkms
  echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
  sudo modprobe v4l2loopback 2>/dev/null || true

  # Screenshot — ShareX is Windows-only.
  # Flameshot covers 95% of its use (annotation, upload, region capture).
  pacin flameshot
  # Bind Flameshot to PrtSc in KDE:
  kwriteconfig6 --file kglobalshortcutsrc \
    --group flameshot --key 'capture' 'Print,Print,Take screenshot'
  ok "OBS + Audacity + Flameshot installed."
  warn "ShareX is Windows-only. Flameshot covers region capture + annotation."
  warn "For advanced upload workflows, check Flameshot's config (upload hooks)."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 19. SYSTEM TWEAKS — performance for both desktop & laptop
# ══════════════════════════════════════════════════════════════════════════════
if section "System tweaks: mirrors · zram · swappiness · fstrim · IRQ balance"; then
  # Fastest mirrors
  if ask "  Refresh pacman mirrorlist (reflector, HTTPS, nearest 10)?"; then
    pacin reflector
    sudo reflector \
      --protocol https \
      --sort rate \
      --latest 10 \
      --save /etc/pacman.d/mirrorlist
    ok "Mirrorlist updated."
  fi

  # zram — compressed swap in RAM (great for 16 GB laptops & desktops)
  if ask "  Enable zram (compressed RAM swap — recommended)?"; then
    pacin zram-generator
    sudo bash -c 'cat > /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0.service || true
    ok "zram enabled."
  fi

  # Swappiness — less aggressive swap (better for dev workloads)
  echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf &>/dev/null
  ok "swappiness → 10."

  # inotify limit — needed for JetBrains IDEs, Docker, large monorepos
  echo "fs.inotify.max_user_watches=524288" \
    | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-inotify.conf &>/dev/null
  ok "inotify watches → 524288 (JetBrains IDEs require this)."

  # fstrim — weekly SSD trim
  sudo systemctl enable --now fstrim.timer
  ok "fstrim.timer enabled."

  # IRQ balance — better CPU distribution on multi-core desktops
  if ask "  Enable irqbalance (recommended for desktops / multi-core)?"; then
    pacin irqbalance
    sudo systemctl enable --now irqbalance
    ok "irqbalance enabled."
  fi

  # Firewall — minimal UFW
  if ask "  Enable UFW firewall (deny in / allow out)?"; then
    pacin ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
    sudo systemctl enable ufw
    ok "UFW enabled."
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# 20. FLATPAK — safety net for anything not in AUR
# ══════════════════════════════════════════════════════════════════════════════
if section "Flatpak (optional safety net)"; then
  pacin flatpak
  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

  FLATPAK_APPS=(
    app.getcleanmymac.CleanMyMac   # placeholder — remove if unwanted
  )

  # Only suggest if user wants extras not covered above
  log "Flathub is now available. Install any app with:"
  log "  flatpak install flathub <app-id>"
  log "Browse: https://flathub.org"
  ok "Flatpak configured."
fi

# ══════════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════════
echo -e ""
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✔  Setup complete.${D}"
echo -e "${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e ""
echo -e "  ${C}Required after reboot:${D}"
echo -e "    ${Y}fnm install --lts${D}              → install Node LTS"
echo -e "    ${Y}npm i -g typescript tsx pnpm prettier eslint${D}"
echo -e "    ${Y}sudo tailscale up${D}              → connect Tailscale"
echo -e "    ${Y}protonup-qt${D}                   → download Proton-GE"
echo -e "    ${Y}jetbrains-toolbox${D}              → install IDEs"
echo -e ""
echo -e "  ${C}JDK switching:${D}"
echo -e "    ${Y}jdk 8 | 11 | 17 | 21 | 25${D}     → switch default JVM"
echo -e "    ${Y}jdk${D}                            → list installed JDKs"
echo -e ""
echo -e "  ${C}Reboot now:${D}  ${Y}sudo reboot${D}"
echo -e ""