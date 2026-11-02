-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Holographic HUD Decorations (conf/decoration.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local colors = require("conf.colors")

hl.config({
    decoration = {
        -- Geometric Great Sage aesthetic (6px sharp-modern corners)
        rounding       = 6,
        rounding_power = 2,

        active_opacity     = 0.96,
        inactive_opacity   = 0.88,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled        = true,
            range          = 22,
            render_power   = 3,
            color          = colors.slime_glow,
            color_inactive = 0x44000000,
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            xray              = false,
            ignore_opacity    = true,
            noise             = 0.015,
            contrast          = 1.05,
            brightness        = 1.05,
            vibrancy          = 0.25,
            vibrancy_darkness = 0.1,
            special           = true,
        },
    },
})

