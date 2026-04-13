local scanners = require'maker.scanners'
local util = require'maker.util'

return scanners.create('dotnet', function ()
  local file = util.match_file'.+[.]csproj'
  if not file then return nil end
  return {
    'dotnet run',
    'dotnet build',
    'dotnet format',
    'dotnet test',
  }
end)
