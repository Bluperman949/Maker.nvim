local M = {}

---@type maker.CommandList
M.known_commands = {}

M.silent = false
M.selected_index = 1
M.command = ''
M.command_outdated = true

return M
