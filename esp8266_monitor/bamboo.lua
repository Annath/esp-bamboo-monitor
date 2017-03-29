local M = {}

function M:get_last_build(hostname, plan_key, username, password, callback)
  print(hostname)
  print(plan_key)
  local url = string.format("http://%s/rest/api/latest/result/%s-latest.json?includeAllStates", hostname, plan_key)
  print(url)

  local auth_string = encoder.toBase64(username .. ":" .. password)
  local headers = string.format("Authorization: Basic %s\r\n", auth_string)
  print(headers)

  http.get(url, headers, function(code, data)
    local build_result = cjson.decode(data)
    callback(code, build_result)
  end)
end

function M:test()
  self:get_last_build("", "", "", "", function(last_build)
    print("build key", last_build.key)
    print("lifeCycleState", last_build.lifeCycleState)
    print("state", "", last_build.state)
  end)
end

return M
