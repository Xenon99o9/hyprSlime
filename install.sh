#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage Interactive Installer & GNU Stow Manager (install.sh)
#  Target OS: CachyOS / Arch Linux (and universal Wayland distributions)
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_CONF_DIR="$REPO_DIR/hypr/.config/hypr/conf"
BACKUP_DIR="$HOME/.config/hyprslime-backup-$(date +%Y%m%d-%H%M%S)"

# ─── Great Sage ANSI Palette ──────────────────────────────────────────────────
CYAN='\033[1;36m'
AZURE='\033[1;34m'
GOLD='\033[1;33m'
PURPLE='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

sage_say() {
    echo -e "${CYAN}◈ « Report:${NC} $1 ${CYAN}»${NC}"
}

sage_ask() {
    echo -e "${GOLD}◈ « Query:${NC} $1 ${GOLD}»${NC}"
}

clear
echo -e "${CYAN}"
cat << 'EOF'
  ╔══════════════════════════════════════════════════════════════════════╗
  ║  ◈  H Y P R S L I M E   —   G R E A T   S A G E   S Y S T E M  ◈    ║
  ║     Tensei Shitara Slime Datta Ken • Modular Hyprland Dotfiles       ║
  ╚══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ─── 1. Optional Arch / CachyOS Package Installation ──────────────────────────
if command -v pacman >/dev/null 2>&1; then
    sage_ask "Arch Linux / CachyOS detected. Install required packages (stow, hyprland, kitty, fish, swww, rofi-wayland, cliphist)?"
    read -rp "  Install dependencies? [y/N]: " install_deps
    if [[ "${install_deps:-N}" =~ ^[Yy]$ ]]; then
        CORE_PKGS=(stow hyprland kitty fish rofi-wayland swww cliphist wl-clipboard grim slurp brightnessctl playerctl polkit-gnome qt6-wayland)
        sage_say "Installing official repository packages via pacman..."
        sudo pacman -S --needed "${CORE_PKGS[@]}"

        # Optional Quickshell check via AUR helper (paru / yay)
        if ! command -v quickshell >/dev/null 2>&1; then
            AUR_HELPER=""
            if command -v paru >/dev/null 2>&1; then AUR_HELPER="paru"; elif command -v yay >/dev/null 2>&1; then AUR_HELPER="yay"; fi
            if [[ -n "$AUR_HELPER" ]]; then
                read -rp "  Install 'quickshell-git' via $AUR_HELPER? [y/N]: " install_qs
                if [[ "${install_qs:-N}" =~ ^[Yy]$ ]]; then
                    "$AUR_HELPER" -S --needed quickshell-git
                fi
            fi
        fi
    fi
fi

# Ensure GNU Stow is present
if ! command -v stow >/dev/null 2>&1; then
    echo -e "${RED}◈ Error: GNU Stow ('stow') is not installed. Please install it first.${NC}"
    exit 1
fi

echo ""
# ─── 2. Hardware / GPU Profile Detection & Selection ──────────────────────────
GPU_INFO="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || true)"
sage_say "Scanning hardware magicule signature..."
if [[ -n "$GPU_INFO" ]]; then
    echo -e "${AZURE}$GPU_INFO${NC}"
fi

echo ""
sage_ask "Select your GPU hardware architecture (for hardware.conf):"
echo "  1) Universal / AMD / Intel only (Default safe Mesa + VA-API)"
echo "  2) Hybrid Laptop: Intel iGPU + NVIDIA dGPU (Optimus / Prime)"
echo "  3) Hybrid Laptop: AMD iGPU + NVIDIA dGPU"
echo "  4) Desktop Dedicated NVIDIA GPU (Proprietary DRM)"
read -rp "  Choice [1-4, default: 1]: " gpu_choice

case "${gpu_choice:-1}" in
    2)
        cat > "$HYPR_CONF_DIR/hardware.conf" << 'EOF'
# ─── Hybrid Laptop: Intel iGPU + NVIDIA dGPU ──────────────────────────────────
env = LIBVA_DRIVER_NAME,iHD
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
        sage_say "Configured Hybrid Intel + NVIDIA profile."
        ;;
    3)
        cat > "$HYPR_CONF_DIR/hardware.conf" << 'EOF'
# ─── Hybrid Laptop: AMD iGPU + NVIDIA dGPU ────────────────────────────────────
env = LIBVA_DRIVER_NAME,radeonsi
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
EOF
        sage_say "Configured Hybrid AMD + NVIDIA profile."
        ;;
    4)
        cat > "$HYPR_CONF_DIR/hardware.conf" << 'EOF'
# ─── Desktop Dedicated NVIDIA GPU ─────────────────────────────────────────────
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
EOF
        sage_say "Configured Dedicated Desktop NVIDIA profile."
        ;;
    *)
        cat > "$HYPR_CONF_DIR/hardware.conf" << 'EOF'
# ─── Universal / AMD / Intel GPU Profile ──────────────────────────────────────
# Native Wayland & Mesa drivers work out-of-the-box without proprietary overrides.
EOF
        sage_say "Configured Universal (AMD / Intel / Portable) GPU profile."
        ;;
esac

echo ""
# ─── 3. Keyboard Layout Selection (Supports Single or Multi-Layout) ───────────
sage_ask "Select your keyboard layout(s) (Switch between multiple with Alt+Shift):"
echo "  1) fr       (French AZERTY)"
echo "  2) us       (English QWERTY)"
echo "  3) fr,us    (Multi-layout: French AZERTY + English QWERTY)"
echo "  4) be       (Belgian AZERTY)"
echo "  5) ch       (Swiss QWERTZ)"
echo "  6) Custom   (Enter comma-separated XKB codes, e.g., 'fr,ca,us')"
read -rp "  Choice [1-6, default: 1]: " kb_choice

case "${kb_choice:-1}" in
    2) SELECTED_KB="us" ;;
    3) SELECTED_KB="fr,us" ;;
    4) SELECTED_KB="be" ;;
    5) SELECTED_KB="ch" ;;
    6)
        read -rp "  Enter XKB layout code(s) (e.g., fr,us): " SELECTED_KB
        SELECTED_KB="${SELECTED_KB:-fr}"
        ;;
    *) SELECTED_KB="fr" ;;
esac
sed -i "s/^[[:space:]]*kb_layout = .*/    kb_layout = $SELECTED_KB/" "$HYPR_CONF_DIR/input.conf"
sage_say "Keyboard layout set to '$SELECTED_KB'."

echo ""
# ─── 4. Default Browser & File Manager Selection ──────────────────────────────
sage_ask "Choose your preferred Web Browser (\$browser):"
echo "  1) brave"
echo "  2) firefox"
echo "  3) zen-browser"
echo "  4) chromium"
read -rp "  Choice [1-4, default: 1 (brave)]: " browser_choice
case "${browser_choice:-1}" in
    2) SELECTED_BROWSER="firefox" ;;
    3) SELECTED_BROWSER="zen-browser" ;;
    4) SELECTED_BROWSER="chromium" ;;
    *) SELECTED_BROWSER="brave" ;;
esac
sed -i "s/^\$browser[[:space:]]*=.*/\$browser     = $SELECTED_BROWSER/" "$HYPR_CONF_DIR/programs.conf"

echo ""
sage_ask "Choose your preferred File Manager (\$fileManager):"
echo "  1) thunar"
echo "  2) dolphin"
echo "  3) nautilus"
echo "  4) kitty -e yazi"
read -rp "  Choice [1-4, default: 1 (thunar)]: " fm_choice
case "${fm_choice:-1}" in
    2) SELECTED_FM="dolphin" ;;
    3) SELECTED_FM="nautilus" ;;
    4) SELECTED_FM="kitty -e yazi" ;;
    *) SELECTED_FM="thunar" ;;
esac
sed -i "s/^\$fileManager[[:space:]]*=.*/\$fileManager = $SELECTED_FM/" "$HYPR_CONF_DIR/programs.conf"

echo ""
# ─── 5. Great Sage Visual Theme & Border Animation Selection ──────────────────
sage_ask "Choose your initial Skill Border Palette (can be changed anytime with Super+Shift+G):"
echo -e "  1) ${GOLD}[Unique Skill: Great Sage]${NC}  Cyan -> Azure -> Golden Eye (#00e5ff / #ffd54f)"
echo -e "  2) ${CYAN}[Slime Core: Pure Magicule]${NC} Cyan -> Azure -> Ice Highlight (#00e5ff / #84ffff)"
echo -e "  3) ${PURPLE}[Ultimate Skill: Beelzebub]${NC} Cyan -> Azure -> Void Purple (#00e5ff / #b388ff)"
read -rp "  Choice [1-3, default: 1]: " theme_choice
case "${theme_choice:-1}" in
    2)
        sed -i 's/^\$active_border.*/$active_border    = $border_magicule/' "$HYPR_CONF_DIR/colors.conf"
        sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_magicule/' "$HYPR_CONF_DIR/colors.conf"
        ;;
    3)
        sed -i 's/^\$active_border.*/$active_border    = $border_beelzebub/' "$HYPR_CONF_DIR/colors.conf"
        sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_beelzebub/' "$HYPR_CONF_DIR/colors.conf"
        ;;
    *)
        sed -i 's/^\$active_border.*/$active_border    = $border_great_sage/' "$HYPR_CONF_DIR/colors.conf"
        sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_great_sage/' "$HYPR_CONF_DIR/colors.conf"
        ;;
esac

echo ""
sage_ask "Choose Magicule Border Animation mode:"
echo "  1) Static Focus Angle (0% idle GPU impact — battery friendly)"
echo "  2) Continuous Magicule Flow (Animated rotating gradient)"
read -rp "  Choice [1-2, default: 1]: " anim_choice
if [[ "${anim_choice:-1}" == "2" ]]; then
    sed -i 's/animation = borderangle.*/animation = borderangle, 1, 45, magiculeFlow, loop/' "$HYPR_CONF_DIR/animations.conf"
else
    sed -i 's/animation = borderangle.*/animation = borderangle, 0, 45, magiculeFlow, loop/' "$HYPR_CONF_DIR/animations.conf"
fi

echo ""
# ─── 6. Safe Backup & GNU Stow Symlink Deployment ─────────────────────────────
PACKAGES=(hypr kitty fish)
sage_ask "Deploy dotfiles to $HOME using GNU Stow (${PACKAGES[*]})?"
read -rp "  Proceed with GNU Stow deployment? [Y/n]: " do_stow

if [[ ! "${do_stow:-Y}" =~ ^[Nn]$ ]]; then
    for pkg in "${PACKAGES[@]}"; do
        target_path="$HOME/.config/$pkg"
        expected_src="$REPO_DIR/$pkg/.config/$pkg"
        
        # If target exists (directory, file OR symlink) and doesn't already point to our repo
        if [[ -e "$target_path" || -L "$target_path" ]]; then
            current_target="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [[ "$current_target" != "$expected_src" ]]; then
                mkdir -p "$BACKUP_DIR"
                sage_say "Backing up existing $target_path -> $BACKUP_DIR/$pkg"
                # If it's a symlink, copy the symlink or move it
                mv -T "$target_path" "$BACKUP_DIR/$pkg" 2>/dev/null || mv "$target_path" "$BACKUP_DIR/$pkg"
            fi
        fi
    done

    cd "$REPO_DIR"
    stow --restow --verbose=1 --target="$HOME" "${PACKAGES[@]}"
    echo ""
    echo -e "${GREEN}◈ « Report: Unique Skill [Great Sage] deployment complete! »${NC}"
    echo -e "  • Press ${GOLD}Super + Shift + G${NC} inside Hyprland (or run ${CYAN}sage${NC} in Fish) to customize live."
else
    sage_say "Configuration files updated in repository without stowing. Run 'stow -t ~ hypr kitty fish' when ready."
fi

