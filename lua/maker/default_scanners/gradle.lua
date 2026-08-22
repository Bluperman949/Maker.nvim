local scanners = require'maker.scanners'
local util = require'maker.util'

return scanners.create('gradle', function ()
  local files = vim.fs.find({ 'build.gradle', 'build.gradle.kts' }, { limit = 64 })
  if #files == 0 then return nil end
  local exe = vim.fs.find('gradlew')[1] and './gradlew ' or 'gradle '

  local tasks = {}

  for _,file in pairs(files) do
    local project = vim.fn.fnamemodify(file, ':.:h')
    project = project == '.' and '' or ':' .. project

    local response = util.shell_command(exe .. project .. ':tasks')
    local project_tasks = util.tbl_map_drop_nil(function (line)
      local match = line:match('^%l%a+ -')
      return match and exe .. project .. ':' .. match:sub(0, -1)
    end, response)

    vim.list_extend(tasks, project_tasks)
  end

  return tasks
end)
