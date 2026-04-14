local scanners = require'maker.scanners'
local util = require'maker.util'

return scanners.create('makefile', function ()
  local file_path = util.find_file{'makefile', 'Makefile', 'MAKEFILE'}
  if not file_path then return {} end
  local lines = util.read_file(file_path)
  local matches = util.tbl_map_drop_nil(function (line)
    local matched_line = line:match('^[%a_]+:')
    return matched_line and 'make ' .. matched_line:sub(1, -2)
  end, lines)
  return matches
end)
