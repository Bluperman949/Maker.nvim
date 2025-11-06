---@class maker.Config
---@field window_command string
---@field make_after_select boolean
---@field disable_default_scanners boolean
---@field keymap maker.ConfigKeymap

---@class maker.UserConfig
---@field window_command string?
---@field make_after_select boolean?
---@field disable_default_scanners boolean?
---@field keymap maker.ConfigKeymap|boolean?

---@class maker.ConfigKeymap
---@field scan string?
---@field make string?
---@field select_build string?
---@field toggle_silent string?

---@class maker.Scanner
---@field name string
---@field enabled maker.ScannerEnabledFunction
---@field run maker.ScannerFunction

---@alias maker.ScannerEnabledFunction function<boolean>
---@alias maker.ScannerFunction function<maker.CommandList>
---@alias maker.CommandList string[]
