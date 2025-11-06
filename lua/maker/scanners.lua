local state = require'maker.state'

local M = {}

---@type maker.Scanner[]
M.scanners = {}

---@param name string
---@param run maker.ScannerFunction
---@param enabled ?maker.ScannerEnabledFunction|boolean
---@return maker.Scanner
M.create = function (name, run, enabled)
  ---@type maker.ScannerEnabledFunction
  local _enabled
  if type(enabled) == 'boolean' then
    _enabled = function () return enabled end
  elseif enabled == nil then
    _enabled = function () return true end
  end

  return {
    name = name,
    run = run,
    enabled = _enabled,
  }
end

---@param scanner maker.Scanner
---@return nil
M.register = function (scanner)
  M.scanners[scanner.name] = scanner
end

M.init_default_scanners = function ()
  M.register(require'maker.default_scanners.makefile')
  M.register(require'maker.default_scanners.zig')
end

M.run_all = function ()
  local results = {}
  for _,scanner in pairs(M.scanners) do
    if scanner.enabled() then
      results[scanner.name] = scanner.run()
    end
  end
  state.known_commands = vim.iter(vim.tbl_values(results)):flatten():totable()
end

return M
