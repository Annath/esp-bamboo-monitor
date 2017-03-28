local animations = require("animations")
local enduser_setup = require("enduser_setup")
local button = require("button")
local bamboo = require("bamboo")

local setup_started = false

local function setup()
  -- not connected to wifi, start setup portal
  if not setup_started then
    print("Starting end user setup")
    enduser_setup.start(
      function()
        print("Connected to wifi")
        setup_started = false
        animations:set_animation("none")
      end,
      function(err, str)
        print("enduser_setup: Err #" .. err .. ": " .. str)
        setup_started = false
      end,
      print
    )
    setup_started = true
  else
    print("End user setup is already running")
  end
end

animations:init(8)
button:init(3, 2000, 300,
  function()
    print("Button held, Disconnecting from wifi")
    wifi.sta.disconnect()
    animations:set_animation("no_network")
  end,
  function()
    print("Button tapped, starting end user setup")
    setup()
  end
)

-- Run every minute
-- If we're online, check bamboo
-- If not, attempt to start the end user setup portal
tmr.create():alarm((1 * 60 * 1000), tmr.ALARM_AUTO, function()
  local wifi_status = wifi.sta.status()
  print("Wifi status:", wifi_status)
  if wifi_status == 5 then
    print("Network up, check bambo...")
    -- TODO Check bamboo and update LEDs accordingly
  else
    animations:set_animation("no_network")
    setup()
  end
end)

