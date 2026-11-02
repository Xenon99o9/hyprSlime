-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — General Layout & HUD Borders (conf/general.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local colors = require("conf.colors")

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = colors.active_border,
            inactive_border = colors.inactive_border,
        },

        resize_on_border        = false,
        extend_border_grab_area = 0,
        allow_tearing           = false,
        layout                  = "dwindle",
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = false,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        vrr                     = 1,
        animate_manual_resizes  = false,
        animate_mouse_windowdragging = false,
    },
})
