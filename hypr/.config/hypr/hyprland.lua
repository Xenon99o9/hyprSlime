-- ══════════════════════════════════════════════════════════════════════════════
--  HYPRSLIME — Great Sage System Interface (hyprland.lua)
--  Native Lua modular configuration for Hyprland 0.57+
-- ══════════════════════════════════════════════════════════════════════════════

local home = os.getenv("HOME")
package.path = home .. "/.config/hypr/?.lua;" .. package.path

-- 1. Hardware & System Environment
require("conf.monitors")
require("conf.hardware")
require("conf.env")
local programs = require("conf.programs")
require("conf.autostart")

-- 2. Great Sage Aesthetics ("Look & Feel")
local colors = require("conf.colors")
require("conf.general")
require("conf.decoration")
require("conf.animations")

-- 3. Controls & Window Management
require("conf.input")
require("conf.keybinds")
require("conf.special")
require("conf.windowrules")
