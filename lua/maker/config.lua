local M = {}

-- when requiring this module, notify a reload
vim.g.loaded_maker = false

---@type maker.Config
M.current_config = nil

---@type maker.Config
local DEFAULT_CONFIG = {
  window_command = 'term',
  make_after_select = true,
  disable_default_scanners = false,
  keymap = {
    scan          = ',r',
    make          = ',,',
    select_build  = ',.',
    toggle_silent = ',s',
  },
}

M.init_if_needed = function ()
  -- only run on first load
  if vim.g.loaded_maker then return end

  M.current_config = vim.tbl_deep_extend('force', DEFAULT_CONFIG, vim.g.maker_config or {})
  vim.g.loaded_maker = true
end

---@param usr_config maker.UserConfig
M.resolve = function (usr_config)
  M.init_if_needed()
  M.current_config = vim.tbl_extend('force', M.current_config, usr_config or {})
  if type(M.current_config.keymap) == 'boolean' then
    M.current_config.keymap = M.current_config.keymap and DEFAULT_CONFIG.keymap or {}
  end
end

return M
