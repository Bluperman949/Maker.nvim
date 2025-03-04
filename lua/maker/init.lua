--
-- maker.nvim
-- Author: Christian Doolittle
-- A small plugin that finds and executes buildscripts.
-- Emphasis on fallbacks maker.nvim should always find your script.
--

local M = {}

    --== RUNTIME VALUES ==--

local silent = false
local opts = {}
local command_index = 1
local commands = {}
local command = "echo 'Maker: no command selected'"

    --== USER COMMANDS ==--

function M.make()
  if silent then
    vim.cmd('silent !'..command)
  else
    vim.cmd(opts.window_command..' '..command)
  end
end

function M.toggle_silent()
  silent = not silent
  if silent then
    print'Make mode: SILENT'
  else
    print'Make mode: VISIBLE'
  end
end

function M.cycle_build()
  command_index = command_index + 1
  if command_index > #commands then command_index = 1 end
  command = commands[command_index]
  print("Maker: selected '"..command.."'")
end

function M.select_build()
  vim.ui.select(commands, {
    prompt = 'Select a build command',
  }, function (choice)
    if not choice then return end
    command = choice;
    command_index = 1;
    if opts.make_after_select then M.make() end
  end)
end

    --== SCANNERS ==--

function M.scan()
  commands = {}
  for _,scanner in ipairs(M.scanners) do
    if not scanner.enabled() then goto continue end
    local results = scanner.run()
    if not results then goto continue end
    for _,v in ipairs(results) do
      commands[#commands+1] = v
    end
    ::continue::
  end
  if #commands == 0 then
    print"Maker: Couldn't find any build commands!"
    return true
  end
  return false
end

function M.create_scanner(name, run, enabled)
  if type(name) ~= 'string' or type(run) ~= 'function'
    or (enabled ~= nil and type(enabled) ~= 'function') then
    print'Maker: failed to create Scanner'
    return nil
  end
  return {
    name = name,
    enabled = enabled or function () return true end,
    run = run,
  }
end

    --== CONFIG HELPERS ==--

function M.find_file(filename)
  return vim.fs.find({filename}, {upward = true})[1]
end

function M.match_in_file(filename, find_pattern)
  --https://neovim.io/doc/user/luaref.html#lua-patterns
  local file = io.open(filename, 'r')
  if file == nil then return nil end
  local ret = {}
  for line in file:lines'l' do
    local m = line:match(find_pattern)
    if m then
      ret[#ret+1] = m
    end
  end
  file:close()
  return ret
end

function M.filter(items, func)
  local ret = {}
  for _,v in ipairs(items) do
    local result = func(v)
    if result ~= nil then
      ret[#ret+1] = result
    end
  end
  return ret
end

function M.shell_command(cmd)
  return vim.split(vim.fn.system(cmd), '\n', {trimempty=true})
end

    --== DEFAULTS ==--

M.scanners = {

  M.create_scanner('makefile', function ()
    local file = M.find_file'makefile'
    if not file then return nil end
    local matches = M.match_in_file(file, '^[%a_]+:%s*$')
    if not matches then return nil end
    return M.filter(matches, function (item)
      return 'make '..item:match'[%a_]+'
    end)
  end),

  M.create_scanner('build.zig', function ()
    local file = M.find_file'build.zig'
    if not file then return nil end
    print'compiling build.zig...'
    local response = M.shell_command'zig build -l'
    print(' ')
    local ret = M.filter(response, function (item)
      return 'zig build '..item:match'[%a_-]+'
    end)
    table.insert(ret, #ret+1, 'zig build')
    return ret
  end),

  M.create_scanner('python', function ()
    -- TODO: separate scanners for BufReadPost
    -- For now, just :MakeScan
    if vim.bo.filetype == 'python' then
      return {'python %'}
    end
  end)

}

local DEFAULT_WINCMD = 'tabnew | term'
local DEFAULT_KEYMAP = {
  make          = ',,',
  cycle_build   = ',n',
  select_build  = ',.',
  toggle_silent = ',s',
}

local vmap = function (lhs, rhs)
  if type(lhs) == 'string' then vim.keymap.set({'n', 'x'}, lhs, rhs) end
end

    --== INITIALIZATION ==--

function M.setup(user_opts)
  opts.window_command = user_opts.window_command or DEFAULT_WINCMD

  if user_opts.keymap == true then opts.keymap = DEFAULT_KEYMAP
  else opts.keymap = user_opts.keymap or DEFAULT_KEYMAP end

  if user_opts.make_after_select == nil then opts.make_after_select = true
  else opts.make_after_select = user_opts.make_after_select == true end

  if user_opts.disable_default_scanners then
    M.scanners = {}
  end
  for _,v in ipairs(user_opts.scanners or {}) do
    M.scanners[#M.scanners+1] = v
  end

  if M.scan() then return end
  command = commands[1]

  vim.api.nvim_create_user_command('Make',       M.make, {})
  vim.api.nvim_create_user_command('MakeCycle',  M.cycle_build, {})
  vim.api.nvim_create_user_command('MakeSelect', M.select_build, {})
  vim.api.nvim_create_user_command('MakeSilent', M.toggle_silent, {})
  vim.api.nvim_create_user_command('MakeScan',   M.scan, {})
  vmap(opts.keymap.make,          M.make)
  vmap(opts.keymap.cycle_build,   M.cycle_build)
  vmap(opts.keymap.select_build,  M.select_build)
  vmap(opts.keymap.toggle_silent, M.toggle_silent)
end

return M
