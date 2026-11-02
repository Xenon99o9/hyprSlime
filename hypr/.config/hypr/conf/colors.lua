-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Great Sage & Rimuru Color Palette (conf/colors.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local M = {
    -- Abyssal Mindscape Surfaces
    bg_void         = "rgba(080c14ee)",
    bg_surface      = "rgba(0f1726cc)",
    bg_inactive     = "rgba(1c294266)",

    -- Rimuru & Magicule Blues
    slime_cyan      = "rgba(00e5ffff)",
    slime_azure     = "rgba(2979ffff)",
    slime_ice       = "rgba(84ffffcc)",

    -- Great Sage & Unique Skills
    sage_gold       = "rgba(ffd54fff)",
    gluttony_purple = "rgba(b388ffff)",
    danger_crimson  = "rgba(ff5252ff)",

    -- Presets
    presets = {
        great_sage = {
            border = { colors = { "rgba(00e5ffff)", "rgba(2979ffff)", "rgba(ffd54fff)" }, angle = 45 },
            glow   = 0x5500e5ff,
        },
        magicule = {
            border = { colors = { "rgba(00e5ffff)", "rgba(2979ffff)", "rgba(84ffffcc)" }, angle = 45 },
            glow   = 0x552979ff,
        },
        beelzebub = {
            border = { colors = { "rgba(00e5ffff)", "rgba(2979ffff)", "rgba(b388ffff)" }, angle = 45 },
            glow   = 0x55b388ff,
        },
    },
}

-- Active preset (Great Sage by default)
M.active_border   = M.presets.great_sage.border
M.slime_glow      = M.presets.great_sage.glow
M.inactive_border = M.bg_inactive

return M

