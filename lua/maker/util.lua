local M = {}

---@param names string|function<string, boolean>|string[]
---@return string?
M.find_file = function (names)
  local found = vim.fs.find(names, {upward = true, type = 'file'})
  if #found > 0 then return found[1] else return nil end
end

---@param filename string
---@return string[]
M.read_file = function (filename)
  local file = io.open(filename, 'r')
  if not file then return {} end
  local content = file:read("*a");
  file:close()
  return vim.split(content, '\n', {trimempty = true})
end

---@generic T, U
---@param func function<T, U?>
---@param t table<any, T>
---@return table<any, U>
M.tbl_map_drop_nil = function (func, t)
  return vim.tbl_filter(function (v) return v ~= nil end, vim.tbl_map(func, t))
end

---@param cmd string
---@return string[]
M.shell_command = function (cmd)
  local content = vim.fn.system(cmd)
  return vim.split(content, '\n', {trimempty=true})
end

return M
