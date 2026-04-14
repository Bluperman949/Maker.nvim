local scanners = require'maker.scanners'
local util = require'maker.util'

return scanners.create('zig', function ()
  local file = util.find_file('build.zig')
  if not file then return nil end
  local response = util.shell_command('zig build -l')
  return vim.tbl_map(function (line)
    return 'zig build ' .. line:match('[%a_-]+')
  end, response)
end)
