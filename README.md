# Maker.nvim

Maker is a simple plugin for NeoVim that finds and executes buildscripts. The
concept is similar to [code_runner.nvim](https://github.com/CRAG666/code_runner.nvim).

This plugin started as a VimL script that added a keybind for running `python
%` in py files and `zig build run` in zig files. When I tried to apply it to
Gradle, I found it hard to pick one universal "run command". I also found that
tying the command to a filetype was limiting. So, here's my first neovim
plugin.

Maker uses customizable units called [Scanners](#scanners) to find all build
systems present in your working directory. These Scanners provide Maker with a
list of shell commands for you to run with a single keybind - a "run button".
The end result is basically the same as other code-runner plugins, but it's
meant to handle situations where one "run button" isn't enough.

## Installation

Minimal configuration is as follows:

### lazy.nvim
```lua
{
  'Bluperman949/Maker.nvim',
  event = 'VeryLazy',
  config = function ()
    require'maker'.setup{}
  end
}
```

<sub>I haven't used any plugin managers aside from lazy.nvim. If you have examples for other plugin managers, please contribute them.</sub>

## Configuration

The `setup` table accepts the following values:

- `window_command`: the Vim command used to open the terminal. Ignored in Silent Mode.\
  default: `'tabnew | term'`\
  accepted: string

- `make_after_select`: whether to run a command immediately after it is selected.\
  default: `true`\
  accepted: boolean

- `keymap`: keymaps for Maker actions. Assigning `true` will explicitly use the default mappings. Specifying your own mappings will nullify ALL default mappings.\
  accepted: table, boolean

  - `scan`: re-run all Scanners to check for new/updated buildscripts.\
    default: `',r'`\
    accepted: string

  - `make`: run the selected build command.\
    default: `',,'`\
    accepted: string

  - `select_build`: select your desired build command from the list of available commands. Uses `vim.ui.select`, affected by decorator plugins.\
    default: `',.'`\
    accepted: string

  - `toggle_silent`: toggle Silent Mode. In Silent Mode, `window_command` will not be executed. Meant for GUI applications where the terminal output is unnecessary.\
    default: `',s'`\
    accepted: string

- `disable_default_scanners`: don't add any Scanners to the Scanner list. See [below](#scanners) for an explanation of Scanners.\
  default: `false`\
  accepted: boolean

### Scanners

A Scanner is just a wrapped function that searches your working directory for a
buildscript and, if one is found, returns a list of valid build commands.

Scanners are meant to be maximally customizable. How? Simple: I make you do all
the work. If you know how to get a list of commands from your buildscript, you
know how to make a Scanner for it.

Well, not *all* the work. I included a few Scanners for the build systems I
use. At the moment, Maker includes Scanners for:
- Makefile
- Zig
- Gradle (half-functional)
- .NET (dumb but functional)

Feel free to contribute your own Scanners or improve mine! I'm always looking
for ways to make this plugin more useful. I'm currently on the lookout for
CMake, better Gradle, and Python.

As an example, here's the default Scanner for Zig, written as if it was a
user's Scanner.

```lua
local maker = require'maker'
local scanners = require'maker.scanners'
local util = require'maker.util'
-- The name 'zig' is only used for registration. You can override a Scanner
-- by registering a new one with the same name.
local my_scanner_for_zig = scanners.create('zig', function ()
  local file = util.find_file('build.zig')
  -- A Scanner should return nil if its buildscript is not present.
  if not file then return nil end
  -- This part is up to you - you could return a literal list of strings,
  -- query your build system for commands, parse the file yourself, etc.
  local response = util.shell_command('zig build -l')
  return vim.tbl_map(function (line)
    return 'zig build ' .. line:match('[%a_-]+')
  end, response)
end)
-- Registration is simple.
maker.register_scanner(my_scanner_for_zig)
```

As you can see, "Scanner" is a nice name for what is just some poorly wrapped
Lua. As long as it returns a list of shell commands, your Scanner is valid.

If you want to only enable a specific default Scanner, you can register it
manually:

```lua
maker.register_scanner(require'maker.default_scanners.name_of_scanner')
```

### Example Configuration

```lua
{
  'Bluperman949/Maker.nvim',
  event = 'VeryLazy',
  config = function ()
    local maker = require'maker'
    maker.setup{
      -- For example, Maker could open an external terminal window.
      window_command = 'silent !kitty --hold --class=runner --',
      -- For explicit default mappings, set `keymap = true`.
      keymap = {
        scan          = ',r',
        make          = ',,',
        select_build  = ',.',
        toggle_silent = ',s',
      },
      disable_default_scanners = true, -- false by default
    }

    -- Scanners can be registered and overridden at any time. It's just
    -- convenient to register them all on startup, so the snippet from the
    -- "Scanners" section should go here.
  end,
}
```
