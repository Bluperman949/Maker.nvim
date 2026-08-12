local M = {}

M.silent = false

---@type table<string, string[]>
M.scan_results = {}

---@type maker.Selection
M.selection = { source = '', index = 0 }

M.command = ''
M.command_outdated = true
M.selection_outdated = true

return M
