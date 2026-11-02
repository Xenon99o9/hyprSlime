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
    lock        = "hyprlock",
    sageMenu    = os.getenv("HOME") .. "/.config/hypr/scripts/great-sage-menu.sh",
}

return M

