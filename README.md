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

  - `make`: run the selected command.\
    default: `',,'`\
    accepted: string

  - `cycle_build`: select the next command in the list of available commands.\
    default: `',n'`\
    accepted: string

  - `select_build`: select your desired build from the list of available commands. Uses `vim.ui.select`, affected by decorator plugins.\
    default: `',.'`\
    accepted: string

  - `toggle_silent`: toggle Silent Mode. `window_command` will not be executed. Meant for UI applications where the terminal output is unnecessary.\
    default: `',s'`\
    accepted: string

- `disable_default_scanners`: don't add any buildscript Scanners to the scanner list.\
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
    maker.setup{
      -- open an external terminal window (tmux users, do your thing)
      window_command = 'silent !kitty --hold --class=runner --',
      -- use default keymaps
      keymap = true,
      disable_default_scanners = true,
      scanners = {
        -- This is just the default makefile scanner.
        -- Normally you'd write your own here.
        maker.create_scanner('makefile', function ()
          local file = maker.find_file'makefile'
          if not file then return nil end
          local matches = maker.match_in_file(file, '^[%a_]+:%s*$')
          if not matches then return nil end
          return maker.filter(matches, function (item)
            return 'make '..item:match'[%a_]+'
          end)
        end),
      },
    }
  end,
}
```
