-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Slime Fluidity & Great Sage Precision (conf/animations.lua)
-- ══════════════════════════════════════════════════════════════════════════════

hl.config({
    animations = {
        enabled = true,
    },
})

-- Custom Bezier Curves
hl.curve("greatSage",    { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.0}  } })
hl.curve("slimeBounce",  { type = "bezier", points = { {0.15, 0.85}, {0.25, 1.06} } })
hl.curve("magiculeFlow", { type = "bezier", points = { {0.0, 0.0},   {1.0, 1.0}  } })

-- Window & Layer Animations
hl.animation({ leaf = "global",           enabled = true,  speed = 5,  bezier = "greatSage" })
hl.animation({ leaf = "windows",          enabled = true,  speed = 4,  bezier = "slimeBounce" })
hl.animation({ leaf = "windowsIn",        enabled = true,  speed = 4,  bezier = "slimeBounce", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 3,  bezier = "greatSage",   style = "popin 85%" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 4,  bezier = "slimeBounce", style = "slide" })
hl.animation({ leaf = "layersIn",         enabled = true,  speed = 3,  bezier = "greatSage",   style = "popin 90%" })
hl.animation({ leaf = "layersOut",        enabled = true,  speed = 2,  bezier = "greatSage",   style = "fade" })
hl.animation({ leaf = "fade",             enabled = true,  speed = 3,  bezier = "greatSage" })
hl.animation({ leaf = "border",           enabled = true,  speed = 5,  bezier = "greatSage" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 45, bezier = "magiculeFlow", style = "loop" })
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 5,  bezier = "greatSage",   style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 4,  bezier = "slimeBounce", style = "slidefadevert -20%" })

