-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Window & Layer Rules (conf/windowrules.lua)
-- ══════════════════════════════════════════════════════════════════════════════

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Floating Utility Dialogs ("Great Sage Analysis Popups")
hl.window_rule({
    name   = "floating-utilities",
    match  = { class = "^(org.pulseaudio.pavucontrol|pavucontrol|nm-connection-editor|blueman-manager|qt6ct|polkit-gnome-authentication-agent-1)$" },
    float  = true,
    center = true,
})

-- Picture-in-Picture (Floating HUD Corner Window)
hl.window_rule({
    name  = "pip-hud",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
})

