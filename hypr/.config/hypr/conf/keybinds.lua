-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Keybindings (conf/keybinds.lua)
--  Universal AZERTY / QWERTY compatibility using physical keycodes for numbers
-- ══════════════════════════════════════════════════════════════════════════════

local programs = require("conf.programs")
local mainMod = "SUPER"

-- ─── Reliable Super-Alone Tap Detection (Zero Misfire on Super + Key) ─────────
_G._hyprslime_super_tap = false
local raw_bind = _G._hyprslime_raw_bind or hl.bind
_G._hyprslime_raw_bind = raw_bind

hl.bind = function(keys, action, opts)
    if type(keys) == "string"
        and keys:upper():find("SUPER")
        and not keys:find("Super_L")
        and not keys:find("Super_R")
        and not (opts and opts.mouse)
    then
        return raw_bind(keys, function()
            _G._hyprslime_super_tap = false
            hl.exec_cmd("quickshell ipc call sage superCancel")
            if type(action) == "function" then
                action()
            else
                hl.dispatch(action)
            end
        end, opts)
    end
    return raw_bind(keys, action, opts)
end

-- Super alone (Tap & Release Super_L / Super_R) -> Open/Close Bottom-Center App Launcher
raw_bind("Super_L", function()
    _G._hyprslime_super_tap = true
    hl.exec_cmd("quickshell ipc call sage superPress")
end, { non_consuming = true, ignore_mods = true })

raw_bind("Super_R", function()
    _G._hyprslime_super_tap = true
    hl.exec_cmd("quickshell ipc call sage superPress")
end, { non_consuming = true, ignore_mods = true })

raw_bind("Super_L", function()
    if _G._hyprslime_super_tap then
        _G._hyprslime_super_tap = false
        hl.exec_cmd("quickshell ipc call sage superRelease || " .. programs.menu)
    end
end, { release = true, non_consuming = true, ignore_mods = true })

raw_bind("Super_R", function()
    if _G._hyprslime_super_tap then
        _G._hyprslime_super_tap = false
        hl.exec_cmd("quickshell ipc call sage superRelease || " .. programs.menu)
    end
end, { release = true, non_consuming = true, ignore_mods = true })

-- Core Applications (Super+S, Super+Escape, Super+D, Super+B are Special Workspaces in conf/special.lua)
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(programs.browser))

-- Great Sage Central Dashboard Menu (Super + M and Super + Shift + G)
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("quickshell ipc call sage toggleSettings || " .. programs.sageMenu))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("quickshell ipc call sage toggleSettings || " .. programs.sageMenu))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("quickshell ipc call sage nextWallpaper"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("quickshell ipc call sage openWallpapers"))
hl.bind(mainMod .. " + H",         hl.dsp.exec_cmd("quickshell ipc call sage toggleKeybinds"))
hl.bind(mainMod .. " + F1",        hl.dsp.exec_cmd("quickshell ipc call sage toggleKeybinds"))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p '◈ Great Sage Memory' | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd(programs.lock))

-- Mouse Bindings & Scroll Workspaces (Super + Click & Drag works on both tiled & floating windows!)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Window Management (Super + Space toggles floating on active window)
hl.bind(mainMod .. " + Space",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Focus Navigation
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move Windows Within Workspace
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Resize Active Window (relative = true is required in Hyprland 0.57 Lua for relative resizing!)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + H",     hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L",     hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + K",     hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J",     hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Workspaces 1-10 using physical keycodes (code:10 to code:19) -> Works on both AZERTY and QWERTY!
-- Automatically exits any open Special Workspace so Super + 1..0 always lands on normal workspaces!
local specialScript = os.getenv("HOME") .. "/.config/hypr/scripts/special-ws.sh"
for i = 1, 10 do
    local keycode = "code:" .. tostring(9 + i)
    hl.bind(mainMod .. " + " .. keycode,         hl.dsp.exec_cmd(specialScript .. " switch-normal " .. tostring(i)))
    hl.bind(mainMod .. " + SHIFT + " .. keycode, hl.dsp.window.move({ workspace = i }))
end

-- Scroll Workspaces (Drag/Resize already configured above with floating lock)

-- Hardware Media & Brightness Keys (Great Sage OSD + Fallback)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("quickshell ipc call sage volumeUp || wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("quickshell ipc call sage volumeDown || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("quickshell ipc call sage volumeMute || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("quickshell ipc call sage micMute || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("quickshell ipc call sage brightnessUp || brightnessctl s 5%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("quickshell ipc call sage brightnessDown || brightnessctl s 5%-"),                        { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                   { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                               { locked = true })
