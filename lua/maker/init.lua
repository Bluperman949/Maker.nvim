--
-- maker.nvim
-- Author: Christian Doolittle
-- A small plugin that finds and executes buildscripts.
-- Emphasis on fallbacks maker.nvim should always find your script.
--

local vmap = function (lhs, rhs)
  if type(lhs) == 'string' then
    vim.keymap.set({'n', 'x'}, lhs, rhs)
  end
end
---@type function
local vcmd = vim.api.nvim_create_user_command

local M = {}

local silent = false
local build_only
local opts = {}
local make_command, build_command, run_command
local DEFAULT_WINCMD = 'tabnew | term'
local DEFAULT_KEYMAP = {
  make          = ',,',
  make_run      = false,
  make_build    = ',.',
  toggle_build  = ',b',
  toggle_silent = ',s',
}

local MAKEFILE_SCANNER = {
  name = 'makefile',
  enabled = function () return true end,
  build_command = 'make build',
  run_command = 'make',
  run = function (self)
    local root = vim.fs.root(0, {'makefile'})
    if not root then return false end
    vim.cmd('cd '..root)
    return true
  end,
}

local function _make(command)
  if silent then
    vim.cmd('silent !'..command)
  else
    vim.cmd(opts.window_command..' '..command)
  end
end

function M.make()       _make(make_command)  end
function M.make_run()   _make(run_command)   end
function M.make_build() _make(build_command) end

-- whether a terminal is shown
function M.toggle_silent()
  silent = not silent
  if silent then
    print'Make mode: SILENT'
  else
    print'Make mode: VISIBLE'
  end
end

function M.toggle_build()
  build_only = not build_only
  if build_only then
    make_command = build_command
    print'Make mode: BUILD'
  else
    make_command = run_command
    print'Make mode: RUN'
  end
end

M.scanners = {}

function M.scan()
  make_command, build_command, run_command = nil, nil, nil
  for _,scanner in ipairs(M.scanners) do
    if scanner.enabled() and scanner:run() then
      build_command = scanner.build_command
      run_command = scanner.run_command
      if build_only then make_command = build_command
      else make_command = run_command end
      return true
    end
  end
  if make_command == nil then
    print"Maker: Couldn't find any buildscripts!"
    return false
  end
end

function M.setup(user_opts)
  opts.window_command = user_opts.window_command or DEFAULT_WINCMD
  if user_opts.keymap == true then opts.keymap = DEFAULT_KEYMAP
  else opts.keymap = user_opts.keymap or DEFAULT_KEYMAP end
  if not user_opts.disable_default_scanners then
    M.scanners[1] = MAKEFILE_SCANNER
  end

  if not M.scan() then return end

  vcmd('Make',       M.make, {})
  vcmd('MakeRun',    M.make_run, {})
  vcmd('MakeBuild',  M.make_build, {})
  vcmd('MakeToggle', M.toggle_build, {})
  vcmd('MakeSilent', M.toggle_silent, {})

  vmap(opts.keymap.make,          M.make)
  vmap(opts.keymap.make_run,      M.make_run)
  vmap(opts.keymap.make_build,    M.make_build)
  vmap(opts.keymap.toggle_build,  M.toggle_build)
  vmap(opts.keymap.toggle_silent, M.toggle_silent)
end

return M
