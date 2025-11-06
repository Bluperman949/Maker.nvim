local state = require'maker.state'
local config = require'maker.config'

local M = {}

M.make = function ()
  if state.command_outdated then
    local prefix = silent and 'silent !' or config.current_config.window_command..' '
    if #state.known_commands == 0 then
      vim.print('No build commands!')
      return
    end
    local command = state.known_commands[state.selected_index]
    state.command = prefix .. command
    state.command_outdated = false
  end
  vim.cmd(state.command)
end

M.select_build = function ()
  vim.ui.select(state.known_commands, {
    prompt = 'Select a build command',
  }, function (_, i)
    if i == nil then return end
    state.command_outdated = true
    state.selected_index = i
    if config.current_config.make_after_select then M.make() end
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
