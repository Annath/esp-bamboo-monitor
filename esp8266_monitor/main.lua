local animations = require("animations")
local ui = require("ui")

local function tap_cb(when)
  print("Tapped at ", when)
end

local function hold_cb(when)
  print("Held at ", when)
end

animations:init(8)
ui:init(3, 2000, 300, hold_cb, tap_cb)
