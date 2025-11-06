local scanners = require'maker.scanners'
local util = require'maker.util'

---@param line string
---@return string?
local match_line = function (line)
  local match = line:match('^%l%a+ -')
  return match and './gradlew ' .. match:sub(0, -1)
end

return scanners.create('gradle', function ()
  local file = util.find_file'gradlew'
  if not file then return nil end
  local response = util.shell_command'./gradlew tasks'
  return util.tbl_map_drop_nil(match_line, response)
end)
