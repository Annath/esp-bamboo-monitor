local M = {
  led_count = 8,
  tick_count = 0,
}

function M.draw()
  if M.animation then
    local led_data = M.animation.draw(M.led_count, M.tick_count)
    ws2812.write(led_data)
    M.tick_count = M.tick_count + 1
  end
end

M.animations = {}

M.animations.running = {
  period_ms = 100,
  draw = function(led_count, tick_count)
    local led_data = ''
    local position = (tick_count % led_count) + 1
    local direction = math.floor(tick_count / led_count) % 2
    if direction == 1 then
      position = led_count - position
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

    return led_data
  end,
}

function M.set_animation(name)
  ws2812.init(ws2812.MODE_SINGLE)
  ws2812.write(string.char(0,0,0):rep(M.led_count))
  M.animation = M.animations[name]
  M.timer = M.timer or tmr.create()
  M.timer:alarm(M.animation.period_ms, tmr.ALARM_AUTO, M.draw)
end

return M
