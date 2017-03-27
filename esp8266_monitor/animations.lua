local M = {
  animations = {},
}

M.animations.none = function(led_count)
  return string.char(0,0,0):rep(led_count), 0
end

M.animations.running = function(led_count, tick_count)
  local led_data = ''
  local position = tick_count % led_count
  local direction = math.floor(tick_count / led_count) % 2
  if direction == 1 then
    position = (led_count - position) + 1
  end

  for i=1,led_count,1 do
      local val = 0
      if math.abs(position - i) == 0 then
          val = 255
      elseif math.abs(position - i) == 1 then
          val = 75
      elseif math.abs(position - i) == 2 then
          val = 10
      end
      led_data = led_data .. string.char(0,0,val)
  end

  return led_data, 75
end

M.animations.success = function(led_count, tick_count)
  local led_data = ''
  local value = tick_count % 255
  local direction = math.floor(tick_count / 255) % 2
  if direction == 1 then
    value = (255 - value) + 1
  end

  led_data = led_data .. string.char(val,0,0):rep(led_count)

  local next_timeout = 0
  
  if (tick_count == 255) then
    next_timeout = 1
  elseif tick_count > 150 and tick_count < 255 then
    next_timeout = 4
  elseif ((tick_count > 125) and (tick_count < 151)) then
    next_timeout = 5
  elseif ((tick_count > 100) and (tick_count < 126)) then
    next_timeout = 7
  elseif ((tick_count > 75) and (tick_count < 101)) then
    next_timeout = 10
  elseif ((tick_count > 50) and (tick_count < 76)) then
    next_timeout = 14
  elseif ((tick_count > 25) and (tick_count < 51)) then
    next_timeout = 18
  elseif (tick_count < 26 and tick_count > 0) then
    next_timeout = 19
  elseif (tick_count == 0) then
    next_timeout = 30
  end

  return led_data, next_timeout
end

function M.tick()
  if M.draw then
    local led_data, delay_ms = M.draw(M.led_count, M.tick_count)
    ws2812.write(led_data)
    M.tick_count = M.tick_count + 1
    if delay_ms > 0 then
      M.timer:alarm(delay_ms, tmr.ALARM_SINGLE, M.tick)
    end
  end
end

function M:set_animation(name)
  self.draw = self.animations[name]
  self.tick()
end

function M:init(led_count)
  self.tick_count = 0
  self.timer = tmr.create()
  self.led_count = led_count
  ws2812.init(ws2812.MODE_SINGLE)
  M:set_animation("none")
end

return M
