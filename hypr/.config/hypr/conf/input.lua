-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Input & Gestures (conf/input.lua)
-- ══════════════════════════════════════════════════════════════════════════════

hl.config({
    input = {
        kb_layout  = "fr,us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
