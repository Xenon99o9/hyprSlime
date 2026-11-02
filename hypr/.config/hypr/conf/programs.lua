-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Default Applications & Commands (conf/programs.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local M = {
    terminal    = "kitty",
    fileManager = "thunar",
    browser     = "brave",
    editor      = "code",
    shell       = "quickshell",
    menu        = "rofi -show drun",
    lock        = "bash -c 'faillock --user \"$USER\" --reset 2>/dev/null || true; sleep 0.15; pidof hyprlock >/dev/null || hyprlock'",
    sageMenu    = os.getenv("HOME") .. "/.config/hypr/scripts/great-sage-menu.sh",
}

return M

