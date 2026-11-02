-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Startup Daemons & Services (conf/autostart.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local programs = require("conf.programs")

hl.on("hyprland.start", function()
    -- System & Authentication Portals
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Wallpaper Daemon & Great Sage HUD Bar
    hl.exec_cmd("~/.config/hypr/scripts/startup-hud.sh")

    -- Clipboard History (cliphist)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Launch initial Great Sage Terminal so the desktop is immediately interactive
    hl.exec_cmd(programs.terminal)
end)

