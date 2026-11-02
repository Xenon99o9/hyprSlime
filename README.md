<div align="center">

# ◈ hyprSlime — Great Sage System Interface ◈

**Modular Hyprland Dotfiles inspired by *That Time I Got Reincarnated as a Slime* (Rimuru / Great Sage HUD), [end-4](https://github.com/end-4/dots-hyprland), and [caelestia-dots](https://github.com/caelestia-dots/shell).**

[![OS](https://img.shields.io/badge/OS-CachyOS%20%2F%20Arch%20Linux-00e5ff?style=for-the-badge&logo=archlinux&logoColor=080c14)](https://cachyos.org/)
[![WM](https://img.shields.io/badge/WM-Hyprland-2979ff?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org/)
[![Shell](https://img.shields.io/badge/HUD-Quickshell-ffd54f?style=for-the-badge&logo=qt&logoColor=080c14)](https://quickshell.outfoxxed.me/)
[![Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-b388ff?style=for-the-badge&logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/)

> *« Report. Unique Skill **[Great Sage]** online. All magicule circuits nominal. »*

</div>

---

## ◈ Aesthetic & Philosophy

**hyprSlime** recreates the geometric, holographic HUD seen inside Rimuru Tempest's mindscape when **Great Sage (*Dai-Kenja* / *Raphael*)** analyzes skills and battle parameters:

- **Abyssal Mindscape Glassmorphism**: Deep midnight void backgrounds (`#080c14`) paired with multi-pass frosted blur and vibrant neon magicule bloom shadows.
- **Geometric Precision + Slime Fluidity**: Sharp `6px` geometric corners and snappy HUD transitions (`greatSage` bezier curve) blended with a subtle organic bounce (`slimeBounce` curve) when spawning or moving windows.
- **3 Live-Switchable Skill Themes**: Switch active border gradients, neon bloom shadows, border rotation, and keyboard layouts on the fly via the built-in **Great Sage Menu** (`Super + Shift + G` or `sage` in terminal).
- **100% Hardware & Layout Portable**: Works out-of-the-box on desktops and laptops across **AMD**, **Intel**, **NVIDIA**, and **Hybrid Optimus** GPUs, as well as **AZERTY**, **QWERTY**, and multi-layout keyboards using physical keycodes (`code:10`–`code:19`).

---

## ◈ Color Palette ("Void & Magicule")

| Role | Name | Hex | Preview |
| :--- | :--- | :--- | :--- |
| **Background (Void)** | Abyssal Mindscape | `#080c14` | `rgba(080c14ee)` |
| **Surface (HUD)** | Holographic Panel | `#0f1726` | `rgba(0f1726cc)` |
| **Primary Accent** | Magicule Cyan | `#00e5ff` | `rgba(00e5ffff)` |
| **Core Accent** | Rimuru Azure | `#2979ff` | `rgba(2979ffff)` |
| **Unique Skill Accent** | Great Sage Gold | `#ffd54f` | `rgba(ffd54fff)` |
| **Ultimate Skill Accent** | Beelzebub Void Purple | `#b388ff` | `rgba(b388ffff)` |
| **Alert / Danger** | Benimaru Crimson | `#ff5252` | `rgba(ff5252ff)` |

---

## ◈ Repository Architecture (GNU Stow)

Each top-level folder is an independent **GNU Stow package** that mirrors `$HOME`:

```text
hyprSlime/
├── install.sh                                # Interactive Great Sage Installer & Stow deployer
├── README.md
│
├── hypr/                                     # Stow package -> ~/.config/hypr/
│   └── .config/
│       └── hypr/
│           ├── hyprland.conf                 # Entrypoint (clean `source = ...` declarations)
│           ├── conf/
│           │   ├── monitors.conf             # Universal high-refresh-rate display detection
│           │   ├── env.conf                  # Wayland & Qt6/Quickshell environment variables
│           │   ├── hardware.conf             # Auto-generated GPU profile (AMD/Intel/NVIDIA/Hybrid)
│           │   ├── programs.conf             # Default apps ($terminal, $browser, $fileManager...)
│           │   ├── autostart.conf            # Daemons (Quickshell, swww, Polkit, cliphist)
│           │   ├── colors.conf               # Rimuru & Great Sage color presets
│           │   ├── general.conf              # Gaps, HUD borders & dwindle layout
│           │   ├── decoration.conf           # 6px geometric corners, neon glow shadow & blur
│           │   ├── animations.conf           # Custom slimeBounce & greatSage bezier curves
│           │   ├── input.conf                # Keyboard layouts (AZERTY/QWERTY/Multi) & gestures
│           │   ├── keybinds.conf             # Layout-agnostic keybindings
│           │   └── windowrules.conf          # Opacity overrides, PiP HUD & layer blur rules
│           └── scripts/
│               └── great-sage-menu.sh        # Live customization menu (Super + Shift + G)
│
├── kitty/                                    # Stow package -> ~/.config/kitty/
│   └── .config/
│       └── kitty/
│           └── kitty.conf                    # Great Sage terminal theme + Slime cursor trail
│
└── fish/                                     # Stow package -> ~/.config/fish/
    └── .config/
        └── fish/
            └── config.fish                   # Great Sage greeting, syntax colors & diamond prompt
```

---

## ◈ Quick Installation

### 1. Clone the repository
```bash
git clone https://github.com/Xenon99o9/hyprSlime.git ~/Documents/projects/hyprSlime
cd ~/Documents/projects/hyprSlime
```

### 2. Run the Interactive Great Sage Installer
The installer automatically detects your GPU, lets you pick your keyboard layout(s) (`fr`, `us`, `fr,us`, etc.), default browser/file manager, and initial Skill Theme, backs up any existing configs to `~/.config/hyprslime-backup-<timestamp>/`, and deploys symlinks via **GNU Stow**:

```bash
./install.sh
```

### Manual GNU Stow Deployment (Optional)
If you prefer to deploy individual packages manually:
```bash
stow --restow --target="$HOME" hypr kitty fish
```

---

## ◈ Keybindings Reference

> **Note:** Workspace bindings use physical keycodes (`code:10` to `code:19`), meaning the top number row (`1`–`0`) works seamlessly on both **AZERTY** and **QWERTY** without pressing `Shift`.

| Shortcut | Action |
| :--- | :--- |
| `Super + Return` / `Super + T` | Launch **Kitty** Terminal |
| `Super + Q` | Close active window (`killactive`) |
| `Super + R` / `Super + Space` | Open Application Launcher (`$menu`) |
| `Super + Shift + G` | Open **◈ Great Sage Live Customization Menu** |
| `Super + E` | Open File Manager (`thunar` by default) |
| `Super + B` | Open Web Browser (`brave` by default) |
| `Super + V` | Open **Great Sage Memory** (Clipboard history via `cliphist`) |
| `Super + F` / `Super + Shift + F` | Toggle Fullscreen / Toggle Floating |
| `Super + S` / `Super + Shift + S` | Toggle / Send window to **"Stomach" Scratchpad** (`special:magic`) |
| `Super + L` | Lock screen (`hyprlock`) |
| `Super + [1-0]` | Switch to Workspace 1–10 |
| `Super + Shift + [1-0]` | Move active window to Workspace 1–10 |
| `Alt + Shift` | Switch between configured keyboard layouts (e.g. `fr` ⇄ `us`) |
| `Print` / `Shift + Print` | Region Screenshot / Fullscreen Screenshot to clipboard |

---

## ◈ 🇫🇷 Guide Rapide (Français)

**hyprSlime** est une configuration Hyprland modulaire gérée avec **GNU Stow**, inspirée de l'interface du **Grand Sage (Raphaël)** dans l'anime *Moi, quand je me réincarne en Slime*, ainsi que des shells **end-4** et **caelestia-dots**.

1. **Installation interactive** : Lancez `./install.sh` pour choisir votre architecture GPU (PC fixe AMD/Intel/NVIDIA ou PC portable hybride Optimus), votre disposition clavier (AZERTY, QWERTY ou plusieurs à la fois avec `Alt + Shift`), vos applications par défaut et votre thème de bordure.
2. **Personnalisation en direct** : Appuyez sur `Super + Shift + G` (ou tapez `sage` dans le terminal Fish) pour ouvrir le menu du Grand Sage et changer instantanément de thème (`Great Sage Gold`, `Pure Magicule Ice`, `Beelzebub Purple`), activer ou couper la rotation de la bordure (économie de batterie), ou changer de clavier.

