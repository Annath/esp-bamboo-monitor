local animations = require("animations")
local enduser_setup = require("enduser_setup")
local button = require("button")
local bamboo = require("bamboo")
local config = require("config")

local setup_started = false

function table_contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

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

animations:init(config.ws2812_led_count)
button:init(config.button_pin, config.button_hold_time_ms, config.button_tap_time_ms,
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

local function poll_build_server(callback)
  bamboo:get_last_build(config.bamboo_hostname,
    config.bamboo_plan,
    config.bamboo_username,
    config.bamboo_password,
    callback)
end

-- If we're online, check bamboo
-- If not, attempt to start the end user setup portal
local function tick()
  local wifi_status = wifi.sta.status()
  print("Wifi status:", wifi_status)
  if wifi_status == 5 then
    print("Network up")
    poll_build_server(function(result)
      if config.state_animation_map[result] ~= nil then
        animations:set_animation(config.state_animation_map[result])
      else
        print("No animation for result:", result)
      end
    end)
  else
    animations:set_animation("no_network")
    if not table_contains({ 1, 2, 3, 4, 5 }, wifi_status) then
      setup()
    end
  end
end

tick()

-- Run every minute
tmr.create():alarm(config.poll_period_ms, tmr.ALARM_AUTO, tick)

