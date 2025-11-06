local scanners = require'maker.scanners'
local util = require'maker.util'

---@param line string
---@return string?
local match_line = function (line)
  ---@type string?
  local matched_line = line:match('^[%a_]+:%s*$')
  return matched_line and 'make ' .. matched_line:match('[%a_]+')
end

return scanners.create('makefile', function ()
  local file_path = util.find_file{'makefile', 'Makefile', 'MAKEFILE'}
  if not file_path then return {} end
  local lines = util.read_file(file_path)
  local matches = util.tbl_map_drop_nil(match_line, lines)
  return matches
end)
