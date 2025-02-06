---@toc lint.toc
---
---@mod lint Main nvim-lint API

local uv = vim.loop
local api = vim.api
local notify = vim.notify_once or vim.notify
local M = {}

--- Running processes by buffer -> by linter name
---@type table<integer, table<string, lint.LintProc>> bufnr: {linter: handle}
local running_procs_by_buf = {}

local namespaces = setmetatable({}, {
  __index = function(tbl, key)
    local ns = api.nvim_create_namespace(key)
    rawset(tbl, key, ns)
    return ns
  end
})


---A table listing which linters to run via `try_lint`.
---The key is the filetype. The values are a list of linter names
---
---Example:
---
---```lua
---require("lint").linters_by_ft = {
---  python = {"ruff", "mypy"}
---}
---```
---
---@type table<string, string[]>
M.linters_by_ft = {
  text = {'vale',},
  json = {'jsonlint',},
  markdown = {'vale',},
  rst = {'vale',},
  ruby = {'ruby',},
  janet = {'janet',},
  inko = {'inko',},
  clojure = {'clj-kondo',},
  dockerfile = {'hadolint',},
  terraform = {'tflint'},
}


--- Run the linters with the given names.
--- If no names are given, it runs the linters configured in `linters_by_ft`
---
---@param names? string|string[] name of the linter
---@param opts? {cwd?: string, ignore_errors?: boolean} options
function M.try_lint(names, opts)
  assert(
    vim.diagnostic,
    "nvim-lint requires neovim 0.6.0+. If you're using an older version, use the `nvim-05` tag of nvim-lint'"
  )
  opts = opts or {}
  if type(names) == "string" then
    names = { names }
  end
  if not names then
    names = M._resolve_linter_by_ft(vim.bo.filetype)
  end

  local lookup_linter = function(name)
    local linter = M.linters[name]
    assert(linter, 'Linter with name `' .. name .. '` not available')
    if type(linter) == "function" then
      linter = linter()
    end
    linter.name = linter.name or name
    return linter
  end

  local bufnr = api.nvim_get_current_buf()
  local running_procs = running_procs_by_buf[bufnr] or {}
  for _, linter_name in pairs(names) do
    local linter = lookup_linter(linter_name)
    local proc = running_procs[linter.name]
    if proc then
      proc:cancel()
    end
    running_procs[linter.name] = nil
    local ok, lintproc_or_error = pcall(M.lint, linter, opts)
    if ok then
      running_procs[linter.name] = lintproc_or_error
    elseif not opts.ignore_errors then
      notify(lintproc_or_error --[[@as string]], vim.log.levels.WARN)
    end
  end
  running_procs_by_buf[bufnr] = running_procs
end


--- Return the namespace for a given linter.
---
--- Can be used to configure diagnostics for a given linter. For example:
---
--- ```lua
--- local ns = require("lint").get_namespace("my_linter_name")
--- vim.diagnostic.config({ virtual_text = true }, ns)
---
--- ```
---
---@param name string linter
function M.get_namespace(name)
  return namespaces[name]
end


--- Returns the names of the running linters
---
---@param bufnr? integer buffer for which to get the running linters. nil=all buffers
---@return string[]
function M.get_running(bufnr)
  local linters = {}
  if bufnr then
    bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
    local running_procs = (running_procs_by_buf[bufnr] or {})
    for linter_name, _ in pairs(running_procs) do
      table.insert(linters, linter_name)
    end
  else
    for _, running_procs in pairs(running_procs_by_buf) do
      for linter_name, _ in pairs(running_procs) do
        table.insert(linters, linter_name)
      end
    end
  end
  return linters
end





---Table with the available linters
---@type table<string, lint.Linter|fun():lint.Linter>
M.linters = setmetatable({}, {
  __index = function(_, key)
    local ok, linter = pcall(require, 'lint.linters.' .. key)
    if ok then
      return linter
    end
    return nil
  end,
})


---A Linter
---@class lint.Linter
---@field name string
---@field cmd string command/executable
---@field args? (string|fun():string)[] command arguments
---@field stdin? boolean send content via stdin. Defaults to false
---Automatically add the current file name to the commands arguments.
---Only has an effect if stdin is false
---@field append_fname? boolean
---@field stream? 'stdout'|'stderr'|'both' result stream. Defaults to stdout
---Declares if exit code != 1 should be ignored or result in a warning. Defaults to false
---@field ignore_exitcode? boolean
---@field env? table
---@field cwd? string
---@field parser lint.Parser|lint.parse


---A currently running lint process
---@class lint.LintProc
---@field bufnr integer
---@field handle uv.uv_process_t
---@field stdout uv.uv_pipe_t
---@field stderr uv.uv_pipe_t
---@field linter lint.Linter
---@field cwd string
---@field ns integer
---@field stream? "stdout"|"stderr"|"both"
---@field cancelled boolean

---Parse function for a linter
---@alias lint.parse fun(output:string, bufnr:number, linter_cwd:string):vim.Diagnostic[]

---Internal Parser
---@class lint.Parser
---@field on_chunk fun(chunk: string)
---@field on_done fun(publish: fun(diagnostics: vim.Diagnostic[]), bufnr: number, linter_cwd: string)


local function read_output(cwd, bufnr, parser, publish_fn)
  return function(err, chunk)
    assert(not err, err)
    if chunk then
      parser.on_chunk(chunk, bufnr)
    else
      parser.on_done(publish_fn, bufnr, cwd)
    end
  end
end


---@private
function M._resolve_linter_by_ft(ft)
  local names = M.linters_by_ft[ft]
  if names then
    return names
  end
  local dedup_linters = {}
  local filetypes = vim.split(ft, '.', { plain = true })
  for _, ft_ in pairs(filetypes) do
    local linters = M.linters_by_ft[ft_]
    if linters then
      for _, linter in ipairs(linters) do
        dedup_linters[linter] = true
      end
    end
  end
  return vim.tbl_keys(dedup_linters)
end


---@private
---@class lint.LintProc
local LintProc = {}
local linter_proc_mt = {
  __index = LintProc
}


function LintProc:publish(diagnostics)
  -- By the time the linter is finished the user might have deleted the buffer
  if api.nvim_buf_is_valid(self.bufnr) and not self.cancelled then
    vim.diagnostic.set(self.ns, self.bufnr, diagnostics)
  end
  self.stdout:shutdown()
  self.stdout:close()
  self.stderr:shutdown()
  self.stderr:close()
end


function LintProc:start_read()
  local linter_proc = self
  local publish = function(diagnostics)
    linter_proc:publish(diagnostics)
  end
  local parser = self.linter.parser
  if type(parser) == 'function' then
    parser = require('lint.parser').accumulate_chunks(parser)
  end
  assert(
    parser.on_chunk and type(parser.on_chunk == 'function'),
    'Parser requires a `on_chunk` function'
  )
  assert(
    parser.on_done and type(parser.on_done == 'function'),
    'Parser requires a `on_done` function'
  )
  local stream = self.linter.stream
  local cwd = self.cwd
  local bufnr = self.bufnr
  if not stream or stream == 'stdout' then
    self.stdout:read_start(read_output(cwd, bufnr, parser, publish))
  elseif stream == 'stderr' then
    self.stderr:read_start(read_output(cwd, bufnr, parser, publish))
  elseif stream == 'both' then
    local parser1, parser2 = require('lint.parser').split(parser)
    self.stdout:read_start(read_output(cwd, bufnr, parser1, publish))
    self.stderr:read_start(read_output(cwd, bufnr, parser2, publish))
  else
    error('Invalid `stream` setting: ' .. stream)
  end
end


function LintProc:cancel()
  self.cancelled = true
  local handle = self.handle
  if not handle or handle:is_closing() then
    return
  end

  -- Use sigint so the process can safely close any child processes.
  -- This is mostly useful for when `cmd` is a script with a shebang.
  handle:kill('sigint')

  vim.wait(10000, function()
    return handle:is_closing() or false
  end)

  if not handle:is_closing() then
    -- 'sigint' didn't work, hit it with a 'sigkill'.
    -- This should also kill any attached child processes since
    -- handle is a process group leader (due to it being detached).
    handle:kill('sigkill')
  end
end


local function eval_fn_or_id(x)
  if type(x) == 'function' then
    return x()
  else
    return x
  end
end

--- Run given function with `cwd` set as :cd, restore original cwd afterwards
---
---@param cwd string
---@param fn fun(...):any
---@return any
local function with_cwd(cwd, fn, ...)
  local curcwd = vim.fn.getcwd()
  if curcwd == cwd then
    return fn(...)
  else
    local mods = { noautocmd = true }
    vim.cmd.cd({cwd, mods = mods})
    local ok, result = pcall(fn, ...)
    vim.cmd.cd({curcwd , mods = mods})
    if ok then
      return result
    end
    error(result)
  end
end


--- Runs the given linter.
--- This is usually not used directly but called via `try_lint`
---
---@param linter lint.Linter
---@param opts? {cwd?: string, ignore_errors?: boolean}
---@return lint.LintProc|nil
function M.lint(linter, opts)
  assert(linter, 'lint must be called with a linter')
  local stdin = assert(uv.new_pipe(false), "Must be able to create pipe")
  local stdout = assert(uv.new_pipe(false), "Must be able to create pipe")
  local stderr = assert(uv.new_pipe(false), "Must be able to create pipe")
  local handle
  local env
  local pid_or_err
  local args = {}
  local bufnr = api.nvim_get_current_buf()
  local iswin = vim.fn.has("win32") == 1
  opts = opts or {}
  local cwd = opts.cwd or linter.cwd or vim.fn.getcwd()

  local function eval(...)
    return with_cwd(cwd, eval_fn_or_id, ...)
  end

  if iswin then
    linter = vim.tbl_extend("force", linter, {
      cmd = "cmd.exe",
      args = { "/C", linter.cmd, unpack(linter.args or {}) },
    })
  end
  if linter.args then
    vim.list_extend(args, vim.tbl_map(eval, linter.args))
  end
  if not linter.stdin and linter.append_fname ~= false then
    table.insert(args, api.nvim_buf_get_name(bufnr))
  end
  if linter.env then
    env = {}
    if not linter.env["PATH"] then
      -- Always include PATH as we need it to execute the linter command
      table.insert(env, "PATH=" .. os.getenv("PATH"))
    end
    for k, v in pairs(linter.env) do
      table.insert(env, k .. "=" .. v)
    end
  end
  local linter_opts = {
    args = args,
    stdio = { stdin, stdout, stderr },
    env = env,
    cwd = cwd,
    -- Linter may launch child processes so set this as a group leader and
    -- manually track and kill processes as we need to.
    -- Don't detach on windows since that may cause shells to
    -- pop up shortly.
    detached = not iswin
  }
  -- prevents cmd.exe taking over the tab title
  if iswin then
    linter_opts.hide = true
  end
  local cmd = eval(linter.cmd)
  assert(cmd, 'Linter definition must have a `cmd` set: ' .. vim.inspect(linter))
  handle, pid_or_err = uv.spawn(cmd, linter_opts, function(code)
    if handle and not handle:is_closing() then
      local procs = (running_procs_by_buf[bufnr] or {})
      -- Only cleanup if there has not been another procs in between
      local proc = procs[linter.name] or {}
      if handle == proc.handle then
        procs[linter.name] = nil
        if not next(procs) then
          running_procs_by_buf[bufnr] = nil
        end
      end
      handle:close()
    end
    if code ~= 0 and not linter.ignore_exitcode then
      vim.schedule(function()
        vim.notify('Linter command `' .. cmd .. '` exited with code: ' .. code, vim.log.levels.WARN)
      end)
    end
  end)
  if not handle then
    stdout:close()
    stderr:close()
    stdin:close()
    if not opts.ignore_errors then
      vim.notify('Error running ' .. cmd .. ': ' .. pid_or_err, vim.log.levels.ERROR)
    end
    return nil
  end
  local state = {
    bufnr = bufnr,
    stdout = stdout,
    stderr = stderr,
    handle = handle,
    linter = linter,
    cwd = linter_opts.cwd,
    ns = namespaces[linter.name],
    cancelled = false,
  }
  local linter_proc = setmetatable(state, linter_proc_mt)
  linter_proc:start_read()
  if linter.stdin then
    local lines = api.nvim_buf_get_lines(0, 0, -1, true)
    for _, line in ipairs(lines) do
      stdin:write(line .. '\n')
    end
    stdin:write('', function()
      stdin:shutdown(function()
        stdin:close()
      end)
    end)
  else
    stdin:close()
  end
  return linter_proc
end


return M
