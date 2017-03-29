local M = {}

function M:get_state(hostname, plan_key, username, password, callback)
  local url = string.format("http://%s/rest/api/latest/result/%s-latest.json?includeAllStates", hostname, plan_key)

  local auth_string = encoder.toBase64(username .. ":" .. password)
  local headers = string.format("Authorization: Basic %s\r\n", auth_string)

  http.get(url, headers, function(code, data)
    local build_result = cjson.decode(data)
    print("Build key", build_result.buildResultKey)
    print("lifeCycleState", build_result.lifeCycleState)
    print("state", build_result.state)

    local result = "unknown"

    if code == 200 then
      if build_result.lifeCycleState == "Finished" then
        result = build_result.state
      else
        result = build_result.lifeCycleState
      end
    else
      result = "HttpError"
      print("HTTP Get failed with code:", code)
    end

    callback(result)
  end)
end

return M
