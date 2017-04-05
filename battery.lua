local M = {}

function M.get_battery_mv(battery_config)
  if battery_config.enabled then
    -- convert to millivolts from raw ADC reading
    local mv = (adc.read(0) * 1000) / battery_config.scaling_factor
    -- Standard voltage divider math
    local div = (battery_config.r2_ohms / (battery_config.r1_ohms + battery_config.r2_ohms))
    local vbatt = mv / div
    print("vbatt (mv):", vbatt)

    return vbatt
  end

  return nil, "Battery measurement disabled"
end

return M