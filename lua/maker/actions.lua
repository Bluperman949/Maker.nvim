local state = require'maker.state'
local config = require'maker.config'
local icons = require'maker.icons'

local M = {}

M.make = function ()
  if state.selection_outdated then M.select_build(true)
  elseif state.command_outdated then
    if next(state.scan_results) == nil then
      vim.print('No build commands!')
      return
    end
    local prefix = state.silent and 'silent !' or config.current_config.window_command .. ' '
    state.command = prefix .. state.command_raw
    state.command_outdated = false
  end
  vim.cmd(state.command)
end

---@param make_after_select boolean?
M.select_build = function (make_after_select)
  local options = {}

  for source,results in pairs(state.scan_results) do
    local icon = icons.get_icon(source)
    for _,command in ipairs(results) do
      options[#options+1] = {
        command = command,
        formatted = icon .. ' ' .. command,
      }
    end
  end

  vim.ui.select(options, {
    prompt = 'Select a build command: ',
    format_item = function (item)
      return item.formatted or item.command
    end,
  }, function (item, _)
    if item == nil then return end
    state.command_raw = item.command
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
