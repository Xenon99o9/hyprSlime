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
        hellflare = {
            border = { colors = { "rgba(ff5252ff)", "rgba(ffd54fff)", "rgba(ff867fff)" }, angle = 45 },
            glow   = 0x55ff5252,
        },
        diablo = {
            border = { colors = { "rgba(e53935ff)", "rgba(0f1726ff)", "rgba(ffd54fff)" }, angle = 45 },
            glow   = 0x55e53935,
        },
        testarossa = {
            border = { colors = { "rgba(ffffffff)", "rgba(ef4444ff)", "rgba(cbd5e1ff)" }, angle = 45 },
            glow   = 0x55ffffff,
        },
        carrera = {
            border = { colors = { "rgba(fbbf24ff)", "rgba(f59e0bff)", "rgba(a855f7ff)" }, angle = 45 },
            glow   = 0x55fbbf24,
        },
        ultima = {
            border = { colors = { "rgba(c084fcff)", "rgba(7c3aedff)", "rgba(10b981ff)" }, angle = 45 },
            glow   = 0x55c084fc,
        },
        mustang = {
            border = { colors = { "rgba(f97316ff)", "rgba(ea580cff)", "rgba(ffd54fff)" }, angle = 45 },
            glow   = 0x55f97316,
        },
    },
}

-- Active preset (Great Sage by default)
M.active_border   = M.presets.magicule.border
M.slime_glow      = M.presets.magicule.glow
M.inactive_border = M.bg_inactive

return M

