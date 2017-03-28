local enduser_setup = require("enduser_setup")
local animations = require("animations")
local ui = require("ui")

local function start()
  print("Starting bamboo ping timer")
  -- TODO start bamboo ping here
end

local function setup()
  -- not connected to wifi, start setup portal
  enduser_setup.start(
    function()
      print("Connected to wifi")
      start()
    end,
    function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
    end
  )
end

local function tap_cb(when)
  print("Button tapped")
  setup()
end

local function hold_cb(when)
  print("Button held")
  print("Disconnecting from wifi")
  wifi.sta.disconnect()
end

local wifi_status = wifi.sta.status()
print("Wifi status:", wifi_status)

if wifi_status == 5 then
  start()
else
  setup()
end

animations:init(8)
ui:init(3, 2000, 300, hold_cb, tap_cb)
