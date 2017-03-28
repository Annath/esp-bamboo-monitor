local M = {}

function M.interrupt_callback(level, when)
  print(level, when)
  
  if level == 0 then
    hold_timer:alarm(150, tmr.ALARM_SINGLE, function()
      hold_callback(when)
    end)
  else

    hold_timer:unregister()

  end
end

function M:init(pin, hold_callback, tap_callback)
  local hold_timer = tmr.create()
  local tap_timer = tmr.create()

  gpio.mode(pin, gpio.INT)
  gpio.trig(pin, "both", function(level, when)
  end)
end

return M