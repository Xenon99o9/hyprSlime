#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage Live Customization Menu (great-sage-menu.sh)
#  Allows instant switching of Skill Border Themes, Magicule Flow, and Keyboards
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

CONF_DIR="$HOME/.config/hypr/conf"
COLORS_FILE="$CONF_DIR/colors.conf"
ANIM_FILE="$CONF_DIR/animations.conf"
INPUT_FILE="$CONF_DIR/input.conf"

# Pick available menu launcher (rofi, fuzzel, wofi)
run_menu() {
    local prompt="$1"
    if command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -i -p "◈ Great Sage: $prompt"
    elif command -v fuzzel >/dev/null 2>&1; then
        fuzzel --dmenu -p "◈ Great Sage: $prompt > "
    elif command -v wofi >/dev/null 2>&1; then
        wofi --dmenu -p "◈ Great Sage: $prompt"
    else
        echo "No menu launcher found (rofi/fuzzel/wofi)." >&2
        exit 1
    fi
}

notify_sage() {
    local title="$1"
    local msg="$2"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "Great Sage" "◈ Report: $title" "$msg"
    fi
}

main_choice=$(printf "%s\n" \
    "1. ◈ Skill Theme (Active Border & Glow)" \
    "2. ◈ Magicule Flow (Border Rotation Animation)" \
    "3. ◈ Keyboard Layout (AZERTY / QWERTY / Multi)" \
    "4. ◈ Window Opacity Mode (Holographic vs Solid)" \
    | run_menu "Select Parameter") || exit 0

case "$main_choice" in
    "1."*)
        theme_choice=$(printf "%s\n" \
            "1. [Unique Skill: Great Sage]  Cyan -> Azure -> Gold (#00e5ff / #ffd54f)" \
            "2. [Slime Core: Pure Magicule] Cyan -> Azure -> Ice  (#00e5ff / #84ffff)" \
            "3. [Ultimate Skill: Beelzebub] Cyan -> Azure -> Void (#00e5ff / #b388ff)" \
            | run_menu "Skill Palette") || exit 0

        case "$theme_choice" in
            "1."*)
                hyprctl keyword general:col.active_border "rgba(00e5ffff) rgba(2979ffff) rgba(ffd54fff) 45deg"
                hyprctl keyword decoration:shadow:color "rgba(00e5ff55)"
                sed -i 's/^\$active_border.*/$active_border    = $border_great_sage/' "$COLORS_FILE"
                sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_great_sage/' "$COLORS_FILE"
                notify_sage "Unique Skill: Great Sage" "Border & Glow updated to Cyan / Azure / Gold."
                ;;
            "2."*)
                hyprctl keyword general:col.active_border "rgba(00e5ffff) rgba(2979ffff) rgba(84ffffcc) 45deg"
                hyprctl keyword decoration:shadow:color "rgba(2979ff55)"
                sed -i 's/^\$active_border.*/$active_border    = $border_magicule/' "$COLORS_FILE"
                sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_magicule/' "$COLORS_FILE"
                notify_sage "Slime Core: Pure Magicule" "Border & Glow updated to 100% Cold Magicule Blue."
                ;;
            "3."*)
                hyprctl keyword general:col.active_border "rgba(00e5ffff) rgba(2979ffff) rgba(b388ffff) 45deg"
                hyprctl keyword decoration:shadow:color "rgba(b388ff55)"
                sed -i 's/^\$active_border.*/$active_border    = $border_beelzebub/' "$COLORS_FILE"
                sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_beelzebub/' "$COLORS_FILE"
                notify_sage "Ultimate Skill: Beelzebub" "Border & Glow updated to Cyan / Void Purple."
                ;;
        esac
        ;;

    "2."*)
        anim_choice=$(printf "%s\n" \
            "1. Static Focus Angle (0% Idle Battery Impact)" \
            "2. Continuous Magicule Flow (Animated Loop)" \
            | run_menu "Border Animation") || exit 0

        case "$anim_choice" in
            "1."*)
                hyprctl keyword animation "borderangle, 0, 45, magiculeFlow, loop"
                sed -i 's/animation = borderangle.*/animation = borderangle, 0, 45, magiculeFlow, loop/' "$ANIM_FILE"
                notify_sage "Magicule Conservation" "Continuous border rotation disabled (Battery Saver)."
                ;;
            "2."*)
                hyprctl keyword animation "borderangle, 1, 45, magiculeFlow, loop"
                sed -i 's/animation = borderangle.*/animation = borderangle, 1, 45, magiculeFlow, loop/' "$ANIM_FILE"
                notify_sage "Magicule Flow Active" "Continuous border rotation enabled."
                ;;
        esac
        ;;

    "3."*)
        kb_choice=$(printf "%s\n" \
            "1. fr       (French AZERTY only)" \
            "2. us       (English QWERTY only)" \
            "3. fr,us    (Both FR + US — Toggle with Alt+Shift)" \
            "4. ch       (Swiss QWERTZ)" \
            "5. be       (Belgian AZERTY)" \
            | run_menu "Keyboard Layout") || exit 0

        selected_kb=$(echo "$kb_choice" | awk '{print $2}')
        hyprctl keyword input:kb_layout "$selected_kb"
        sed -i "s/^[[:space:]]*kb_layout = .*/    kb_layout = $selected_kb/" "$INPUT_FILE"
        notify_sage "Language Matrix Updated" "Keyboard layout set to: $selected_kb (Alt+Shift to toggle)."
        ;;

    "4."*)
        op_choice=$(printf "%s\n" \
            "1. Holographic HUD (0.96 Active / 0.88 Inactive)" \
            "2. Solid Opaque (1.0 Active / 1.0 Inactive)" \
            | run_menu "Window Opacity") || exit 0

        case "$op_choice" in
            "1."*)
                hyprctl keyword decoration:active_opacity 0.96
                hyprctl keyword decoration:inactive_opacity 0.88
                notify_sage "Holographic Mode" "Window translucency enabled."
                ;;
            "2."*)
                hyprctl keyword decoration:active_opacity 1.0
                hyprctl keyword decoration:inactive_opacity 1.0
                notify_sage "Solid Mode" "Windows set to 100% opaque."
                ;;
        esac
        ;;
esac

