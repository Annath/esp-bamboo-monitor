local M = {
  held = false,
  tap_expired = false,
}

function M:init(pin, hold_time, tap_time, hold_callback, tap_callback)
  local hold_timer = tmr.create()
  local tap_timer = tmr.create()

  gpio.mode(pin, gpio.INT)
  gpio.trig(pin, "both", function(level, when)
    if level == 0 then
      hold_timer:alarm(hold_time, tmr.ALARM_SINGLE, function()
        M.held = true
        hold_callback(when)
      end)

      tap_timer:alarm(tap_time, tmr.ALARM_SINGLE, function()
        M.tap_expired = true
      end)
    else
      hold_timer:unregister()
      tap_timer:unregister()
      
      if not M.held and not M.tap_expired then
        tap_callback(when)
      end

      M.held = false
      M.tap_expired = false
    end
  end)
end

return M