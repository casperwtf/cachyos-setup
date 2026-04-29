# cachyos-setup

post-install scripts for CachyOS KDE. built for my own use, sharing it anyway.

```bash
mkdir -p ~/cachyos-setup && curl -fsSL https://api.github.com/repos/casperwtf/cachyos-setup/tarball/main | tar -xz -C ~/cachyos-setup --strip-components=1 && bash ~/cachyos-setup/install.sh
```

---

## what it installs

**setup.sh** — run this first on a fresh install.

- browsers: vivaldi, librewolf, chromium, ungoogled chromium, tor
- comms: discord + canary, slack, rocket.chat, signal
- editors: zed, vscode (minimal config), jetbrains toolbox (intellij / rider / pycharm / webstorm)
- JDKs: 8, 11, 17, 21, 25 with a `jdk <version>` switcher in fish
- dev: git, docker, node (fnm), bun, typescript, python, github cli
- db clients: mongodb compass, dbeaver, sqlitebrowser
- devops: lens, minikube, kubectl
- vpn/net: mullvad, tailscale, wireguard, wireshark
- gaming: steam, prism launcher, gamemode, mangohud, protonup-qt
- android: adb, scrcpy, mtp
- misc: 1password, thunderbird, linear, gitbutler, spotify, obs, audacity, yourkit, blockbench, bruno, redisinsight, nats

terminal is wezterm + fish + starship, config written out automatically.

**rice.sh** — KDE theming. run after you've logged into a KDE session.

- rosé pine color scheme (warm dark)
- thin top bar: `[⊞] ─── [date · time] ─── [tray]`, no taskbar
- meta key opens window overview
- klassy window decorations, papirus-dark icons
- wallpapers from `wallpapers/` on 30 min rotation
- gtk 3+4 themed so firefox etc. don't look broken

---

## repo layout

```
cachyos-setup/
├── install.sh          one-liner entry point
├── setup.sh            packages
├── rice.sh             KDE theming
└── wallpapers/
    ├── fetch.sh        called by rice.sh, copies wallpapers to ~/.local/...
    └── *.png / *.jpg   bundled wallpapers
```

---

## notes

- requires paru (setup.sh installs it if missing)
- rice.sh needs plasmashell running — don't run from tty
- JDK switching: `jdk 17` sets default, bare `jdk` lists installed
- after setup run `fnm install --lts` then `npm i -g typescript tsx pnpm`
- jetbrains toolbox handles the IDEs — launch it after setup
- sharex doesn't exist on linux — flameshot is included instead

tested on CachyOS KDE (plasma 6). probably fine on other arch-based KDE installs.