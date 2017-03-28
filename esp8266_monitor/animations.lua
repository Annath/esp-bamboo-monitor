local M = {
  animations = {},
}

M.animations.none = function(led_count)
  return string.char(0,0,0):rep(led_count), 0
end

M.animations.no_network = function(led_count, tick_count)
  local value = 0
  if (tick_count % 2) == 0 then
    value = 100
  end
  return (string.char(value,value,value) .. string.char(0,0,0):rep(led_count)), 500
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

local function breathing(colors)
  return function(led_count, tick_count)
    local led_data = ''
    local value = tick_count % 255
    local direction = math.floor(tick_count / 255) % 2
    if direction == 1 then
      value = (255 - value)
    end

    local red = colors.red and value or 0
    local blue = colors.blue and value or 0
    local green = colors.green and value or 0
    led_data = led_data .. string.char(green,red,blue):rep(led_count)

    local next_timeout = 0
    
    if value == 255 then
      next_timeout = 1
    elseif value > 150 and value < 255 then
      next_timeout = 4
    elseif value > 125 and value < 151 then
      next_timeout = 5
    elseif value > 100 and value < 126 then
      next_timeout = 7
    elseif value > 75 and value < 101 then
      next_timeout = 10
    elseif value > 50 and value < 76 then
      next_timeout = 14
    elseif value > 25 and value < 51 then
      next_timeout = 18
    elseif value < 26 and value > 0 then
      next_timeout = 19
    elseif value == 0 then
      next_timeout = 30
    end

    return led_data, next_timeout
  end
end

M.animations.failure = breathing{
  red = true
}

M.animations.success = breathing{
  green = true
}

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
  if self.draw ~= self.animations[name] then
    self:reset()
    self.draw = self.animations[name]
    self.tick()
  end
end

function M:reset()
  self.tick_count = 0
end

function M:init(led_count)
  self.led_count = led_count
  self.timer = tmr.create()
  self:reset()
  ws2812.init(ws2812.MODE_SINGLE)
  M:set_animation("none")
end

return M
