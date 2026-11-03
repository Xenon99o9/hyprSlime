-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Dynamic Caelestia Special Workspaces (conf/special.lua)
-- ══════════════════════════════════════════════════════════════════════════════

local home = os.getenv("HOME")
local script = home .. "/.config/hypr/scripts/special-ws.sh"

hl.bind("SUPER + S", hl.dsp.exec_cmd(script .. " toggle 'music'"))
hl.window_rule({ name = "special-music", match = { class = "^(Spotify|spotify)$" }, workspace = "special:music" })
hl.bind("SUPER + Escape", hl.dsp.exec_cmd(script .. " toggle 'sysmon'"))
hl.window_rule({ name = "special-sysmon", match = { class = "^(sysmon-btop)$" }, workspace = "special:sysmon" })
hl.bind("SUPER + D", hl.dsp.exec_cmd(script .. " toggle 'chat'"))
hl.window_rule({ name = "special-chat", match = { class = "^(discord|vesktop|WebCord)$" }, workspace = "special:chat" })
