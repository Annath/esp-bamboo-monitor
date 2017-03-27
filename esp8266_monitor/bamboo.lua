local M = {}

function M:get_last_build(bamboo_base_url, plan_key, username, password, callback)
  local url = string.format("%s/result/%s.json?includeAllStates", bamboo_base_url, plan_key)
  local headers = ""
  http.get(url, headers, function(code, data)
    local plan_result = cjson.decode(data)
    local last_build = plan_result.results.result[1]
    callback(last_build)
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
