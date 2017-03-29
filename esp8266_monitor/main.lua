local animations = require("animations")
local enduser_setup = require("enduser_setup")
local button = require("button")
local bamboo = require("bamboo")

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

-- If we're online, check bamboo
-- If not, attempt to start the end user setup portal
local function tick()
  local wifi_status = wifi.sta.status()
  print("Wifi status:", wifi_status)
  if wifi_status == 5 then
    print("Network up, check bambo...")
    bamboo:get_last_build("bamboo.actigraph.office:8085",
      "CDH-BT5",
      "monitor",
      ".e&KzB.B9j}aK5,CE9",
      function(code, last_build)
        print(code)
        if code == 200 then
          print("Build key", last_build.buildResultKey)
          print("lifeCycleState", last_build.lifeCycleState)
          print("state", last_build.state)

          if last_build.lifeCycleState == "InProgress" then
            animations:set_animation("running")
          elseif last_build.lifeCycleState == "Finished" then
            if last_build.state == "Successful" then
              animations:set_animation("success")
            elseif last_build.state == "Failed" then
              animations:set_animation("failure")
            else
              print("No animation for state ", last_build.state)
            end
          end
        end
      end
    )
  else
    animations:set_animation("no_network")
    if not table_contains({ 1, 2, 3, 4, 5 }, wifi_status) then
      setup()
    end
  end
end

tick()

-- Run every minute
tmr.create():alarm((1 * 60 * 1000), tmr.ALARM_AUTO, tick)

