local actions = require'maker.actions'
local scanners = require'maker.scanners'
local config = require'maker.config'

local M = {}

M.scan = scanners.run_all
M.make = actions.make
M.select_build = actions.select_build
M.toggle_silent = actions.toggle_silent

M.create_scanner = scanners.create
M.register_scanner = scanners.register

---@param usr_config maker.UserConfig
M.setup = function (usr_config)
  config.resolve(usr_config)
  for action_name,keys in pairs(config.current_config.keymap) do
    vim.keymap.set('n', keys, M[action_name], {})
  end
  if not config.current_config.disable_default_scanners then
    scanners.init_default_scanners()
  end
  M.scan()
end

return M
