local scanners = require'maker.scanners'
local util = require'maker.util'

return scanners.create('dotnet', function ()
  local base_commands = {
    'dotnet build',
    'dotnet format',
    'dotnet clean',
  }

  local file = util.match_file('.+[.]csproj')

  -- If in project dir, we can try to run this project directly.
  if file then
    table.insert(base_commands, 1, 'dotnet run')
    table.insert(base_commands, 2, 'dotnet test')
    return base_commands
  end

  -- otherwise, search subdirs for executable projects
  file = util.match_file('.+[.]sln')

  local projects = vim.split(vim.fn.glob('*/*.csproj'), '%s')
  local proj_commands = util.tbl_map_drop_nil(function (proj_path)
    local proj_file = io.open(proj_path, 'r')
    if not proj_file then return nil end
    local proj_xml = proj_file:read("*a")

    -- get project dir name
    local proj_name = vim.fn.fnamemodify(proj_path, ':h')
    local command = nil

    -- look for keywords suggesting this project is runnable or for testing
    if proj_xml:match('Exe') then
      command = 'dotnet run --project '..proj_name
    elseif proj_xml:match('Test') then
      command = 'dotnet test '..proj_name
    end

    proj_file:close()
    return command;
  end, projects)

  vim.list_extend(proj_commands, base_commands)

  return proj_commands
end)
