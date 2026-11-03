#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage HUD & Wallpaper Startup Script (startup-hud.sh)
# ══════════════════════════════════════════════════════════════════════════════

WALL_CACHE="$HOME/.cache/hyprslime-wallpaper"
WALLPAPER="$HOME/.config/hypr/wallpapers/rimuru-great-sage.png"
if [[ -r "$WALL_CACHE" ]]; then
    cached_wall="$(cat "$WALL_CACHE" 2>/dev/null || true)"
    [[ -n "$cached_wall" && -f "$cached_wall" ]] && WALLPAPER="$cached_wall"
fi

if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -d "/run/user/$(id -u)/hypr" ]]; then
    sig=$(ls -t "/run/user/$(id -u)/hypr" 2>/dev/null | head -n 1 || true)
    [[ -n "$sig" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
fi
hyprctl reload >/dev/null 2>&1 || true

# 1. Stop any legacy bars (waybar / old quickshell instances)
pkill -x waybar 2>/dev/null || true
pkill -x quickshell 2>/dev/null || true
pkill -x qs 2>/dev/null || true

# 2. Start Wallpaper Daemon (swww or awww) & Apply Great Sage Mindscape Wallpaper
if command -v swww-daemon >/dev/null 2>&1; then
    pgrep -x swww-daemon >/dev/null || swww-daemon --format xrgb &
    sleep 0.5
    [[ -f "$WALLPAPER" ]] && swww img "$WALLPAPER" --transition-type center --transition-fps 120 &
elif command -v awww-daemon >/dev/null 2>&1; then
    pgrep -x awww-daemon >/dev/null || awww-daemon --format xrgb &
    sleep 0.5
    [[ -f "$WALLPAPER" ]] && awww img "$WALLPAPER" --transition-type center --transition-fps 120 &
fi

# 3. Start Notification Daemon (SwayNC)
if command -v swaync >/dev/null 2>&1; then
    pgrep -x swaync >/dev/null || swaync &
fi

# 4. Start Great Sage Top Bar, Keybinds Sheet & Control Center (Quickshell)
if command -v quickshell >/dev/null 2>&1; then
    hyprctl dispatch 'hl.dsp.exec_cmd("quickshell")' >/dev/null 2>&1 || nohup quickshell </dev/null >/dev/null 2>&1 &
elif command -v qs >/dev/null 2>&1; then
    hyprctl dispatch 'hl.dsp.exec_cmd("qs")' >/dev/null 2>&1 || nohup qs </dev/null >/dev/null 2>&1 &
fi

# 5. Idle Daemon
command -v hypridle >/dev/null 2>&1 && { pgrep -x hypridle >/dev/null || hypridle & }

# 6. Great Sage Startup Report Notification
sleep 1.2
if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Great Sage" "◈ Unique Skill [Great Sage]" "HUD initialized. Press Super+H for Keybinds or Super+Shift+G for Control Center."
fi
