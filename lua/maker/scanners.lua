local state = require'maker.state'

local M = {}

---@type maker.Scanner[]
local registered_scanners = {}

---@param name string
---@param run maker.ScannerFunction
---@param enabled ?maker.ScannerEnabledFunction|boolean
---@return maker.Scanner
M.create = function (name, run, enabled)
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
M.register = function (scanner)
  registered_scanners[scanner.name] = scanner
end

M.register_default_scanners = function ()
  M.register(require'maker.default_scanners.makefile')
  M.register(require'maker.default_scanners.zig')
  M.register(require'maker.default_scanners.gradle')
  M.register(require'maker.default_scanners.csproj')
end

---@param scanner maker.Scanner|string
local run = function (scanner)
  if type(scanner) == "string" then
    scanner = registered_scanners[scanner]
  end
  state.scan_results[scanner.name] = {}
  if scanner.enabled() then
    state.scan_results[scanner.name] = scanner.run()
  end
end

M.run_all = function ()
  for _, scanner in pairs(registered_scanners) do
    run(scanner)
  end
end

---@param name string
M.run_single = function (name)
  local scanner = registered_scanners[name]
  if scanner == nil then return end
  run(scanner)
end

return M
