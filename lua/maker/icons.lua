local M = {}

local icons = {}
local devicons = nil
pcall(function () devicons = require'nvim-web-devicons' end)

---@param name string
---@param icon string
---@param cterm_color integer?
M.set_icon = function (name, icon, cterm_color)
  if cterm_color then
    icons[name] = '\x1B[;38;5;' .. cterm_color .. 'm' .. icon .. '\x1B[0m'
  else
    icons[name] = icon
  end
end

---@param name string
---@return string
M.get_icon = function (name)
  if not icons[name] and devicons then
    local devicon, cterm_color = devicons.get_icon_cterm_color(name)
    if devicon and cterm_color then
      icons[name] = '\x1B[;38;5;' .. cterm_color .. 'm' .. devicon .. '\x1B[0m'
    end
  end
  return icons[name] or '\x1B[32m>_\x1B[0m'
end

return M
