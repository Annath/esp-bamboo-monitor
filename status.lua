local M = {}

function M:send(url, name, current_animation, battery_voltage_mv, user_status)
  local headers = "Content-Type: application/json\r\n"
  local body = cjson.encode{
    name = name,
    current_animation = current_animation,
    battery_voltage_mv = battery_voltage_mv,
    user_status = user_status,
  }

  http.post(url, headers, body, function(code, body, headers)
    print("Response code = ", code)
    print("Response body = ", body)
  end)
end

return M
