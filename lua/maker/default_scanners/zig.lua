local scanners = require'maker.scanners'
local util = require'maker.util'

---@param line string
local match_line = function (line)
  return 'zig build ' .. line:match('[%a_-]+')
end

return scanners.create('zig', function ()
  local file = util.find_file('build.zig')
  if not file then return nil end
  local response = util.shell_command('zig build -l')
  return vim.tbl_map(match_line, response)
end)
