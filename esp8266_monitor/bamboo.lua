local M = {}

function M:get_last_build(hostname, plan_key, username, password, callback)
  print(hostname)
  print(plan_key)
  local url = string.format("https://%s/rest/api/latest/result/%s.json?includeAllStates", hostname, plan_key)

  local auth_string = encoder.toBase64(username .. ":" .. password)
  local headers = string.format("Authorization: Basic %s\r\n", auth_string)

  http.get(url, headers, function(code, data)
    local plan_result = cjson.decode(data)

    if plan_result.results ~= nil
      and plan_result.results.result ~= nil
      and plan_result.results.result[1] ~= nil
    then
      local last_build = plan_result.results.result[1]
      callback(last_build)
    else
      print(data)
    end
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
