# Maker.nvim

Maker is a simple plugin for NeoVim that finds and executes buildscripts. The concept is similar to [code_runner.nvim](https://github.com/CRAG666/code_runner.nvim).

This plugin started as a VimL script that mapped `<A-r>` to `python %` in py files and `zig build run` in zig files. When I tried to apply it to Gradle, I found it hard to pick one universal "run command". I also found that tying the command to a filetype was limiting. So, here's my first neovim plugin.

I'll be adding more default Scanners as time goes on. If you've written a Scanner and feel like it could be useful to others, please PR it!

## Installation

Minimal configuration is as follows:

### lazy.nvim
```lua
{
  'Bluperman949/Maker.nvim',
  event = 'VeryLazy',
  config = function ()
    require'maker'.setup{
    }
  end
}
```

<sub>I haven't used any plugin managers aside from lazy.nvim. If you have examples for other plugin managers, please contribute them.</sub>

## Configuration

The `setup` table accepts the following values:

- `window_command`: the vim command used to open the terminal. Ignored in Silent Mode.\
  default: `'tabnew | term'`\
  accepted: string

- `make_after_select`: whether to run a command immediately after it is selected.\
  default: `true`\
  accepted: boolean

- `keymap`: keymaps for Maker functions. Assigning `true` will explicitly use the default mappings. Specifying your own mappings will nullify ALL default mappings.\
  accepted: table, boolean

  - `scan`: run all Scanners to check for new buildscripts.\
    default: `',r'`\
    accepted: string

  - `make`: run the selected command.\
    default: `',,'`\
    accepted: string

  - `select_build`: select your desired build from the list of available commands. Uses `vim.ui.select`, affected by decorator plugins.\
    default: `',.'`\
    accepted: string

  - `toggle_silent`: toggle Silent Mode. `window_command` will not be executed. Meant for GUI applications where the terminal output is unnecessary.\
    default: `',s'`\
    accepted: string

- `disable_default_scanners`: don't add any Scanners to the Scanner list.\
  default: `false`\
  accepted: boolean

- `scanners`: a list of Scanners to be added to the queue. See [below](#scanners) for an explanation of Scanners.\
  default: `{}`\
  accepted: table

### Scanners

<sub>I haven't written this part yet. Annoy me about it.</sub>

### Example Configuration

```lua
{
  'Bluperman949/Maker.nvim',
  event = 'VeryLazy',
  config = function ()
    local maker = require'maker'
    local util = require'maker.util'
    maker.setup{
      -- for example, Maker can open an external terminal window
      window_command = 'silent !kitty --hold --class=runner --',
      keymap = true,
      disable_default_scanners = true,
      scanners = {
        -- This is just the default makefile scanner for demonstration purposes.
        -- Normally you'd write your own here.
        local my_makefile_scanner = maker.create_scanner('makefile', function ()
          local file_path = util.find_file{'makefile', 'Makefile', 'MAKEFILE'}
          if not file_path then return {} end
          local lines = util.read_file(file_path)
          local matches = util.tbl_map_drop_nil(function (line)
            local _line = line:match('^[%a_]+:%s*$')
            return _line and 'make ' .. matched_line:match('[%a_]+')
          end, lines)
          return matches
        end)
        maker.register_scanner(my_makefile_scanner)
      },
    }
  end,
}
```
