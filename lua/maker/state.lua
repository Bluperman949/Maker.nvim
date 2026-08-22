local M = {}

M.silent = false

---@type table<string, string[]>
M.scan_results = {}

M.command_raw = ''
M.command = ''
M.command_outdated = true
M.selection_outdated = true

return M
