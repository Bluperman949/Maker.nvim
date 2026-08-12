local state = require'maker.state'
local config = require'maker.config'

local M = {}

M.make = function ()
  if state.selection_outdated then M.select_build(true)
  elseif state.command_outdated then
    local prefix = state.silent and 'silent !' or config.current_config.window_command..' '
    if next(state.scan_results) == nil then
      vim.print('No build commands!')
      return
    end
    local command = state.scan_results[state.selection.source][state.selection.index]
    state.command = prefix .. command
    state.command_outdated = false
  end
  vim.cmd(state.command)
end

---@param make_after_select boolean?
M.select_build = function (make_after_select)
  ---@type maker.Selection[], string[]
  local options, commands = {}, {}

  for source,results in pairs(state.scan_results) do
    for index,command in ipairs(results) do
      options[#options+1] = { source = source, index = index }
      commands[#commands+1] = '[' .. source .. ']  ' .. command
    end
  end

  vim.ui.select(commands, {
    prompt = 'Select a build command: ',
  }, function (_, i)
    if i == nil then return end
    state.selection = options[i]
    state.selection_outdated = false
    state.command_outdated = true
    if make_after_select or config.current_config.make_after_select then
      M.make()
    end
  end)
end

---@param silent boolean
M.set_silent = function (silent)
  state.command_outdated = true
  state.silent = silent
  vim.print('Make silently: ' .. (silent and 'ON' or 'OFF'))
end

M.toggle_silent = function ()
  M.set_silent(not state.silent)
end

return M
