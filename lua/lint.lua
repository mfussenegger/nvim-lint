local uv = vim.loop
local api = vim.api
local notify
if vim.notify_once then
  notify = vim.notify_once
else
  notify = vim.notify
end
local M = {}


---@class lint.Parser
---@field on_chunk fun(chunk: string)
---@field on_done fun(publish: fun(diagnostics: Diagnostic[]), bufnr: number, linter_cwd: string)


---@class lint.Linter
---@field name string
---@field cmd string
---@field args? (string|fun():string)[] command arguments
---@field stdin? boolean send content via stdin. Defaults to false
---@field append_fname? boolean add current file name to the commands arguments
---@field stream? "stdout"|"stderr"|"both" result stream. Defaults to stdout
---@field ignore_exitcode? boolean if exit code != 1 should be ignored or result in a warning. Defaults to false
---@field env? table
---@field cwd? string
---@field parser lint.Parser|fun(output:string, bufnr:number, linter_cwd:string):Diagnostic[]


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

local namespaces = setmetatable({}, {
  __index = function(tbl, key)
    local ns = api.nvim_create_namespace(key)
    rawset(tbl, key, ns)
    return ns
  end
})


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


local function start_read(stream, cwd, stdout, stderr, bufnr, parser, ns)
  local publish = function(diagnostics)
    -- By the time the linter is finished the user might have deleted the buffer
    if api.nvim_buf_is_valid(bufnr) then
      vim.diagnostic.set(ns, bufnr, diagnostics)
    end
    stdout:shutdown()
    stdout:close()
    stderr:shutdown()
    stderr:close()
  end
  if not stream or stream == 'stdout' then
    stdout:read_start(read_output(cwd, bufnr, parser, publish))
  elseif stream == 'stderr' then
    stderr:read_start(read_output(cwd, bufnr, parser, publish))
  elseif stream == 'both' then
    local parser1, parser2 = require('lint.parser').split(parser)
    stdout:read_start(read_output(cwd, bufnr, parser1, publish))
    stderr:read_start(read_output(cwd, bufnr, parser2, publish))
  else
    error('Invalid `stream` setting: ' .. stream)
  end
end

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


--- Running processes by buffer -> by linter name
---@type table<integer, table<string, uv.uv_process_t>> bufnr: {linter: handle}
local running_procs_by_buf = {}


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
  for linter_name, proc in pairs(running_procs) do
    if not proc:is_closing() then
      proc:kill("sigterm")
    end
    running_procs[linter_name] = nil
  end

  for _, linter_name in pairs(names) do
    local linter = lookup_linter(linter_name)
    local ok, handle_or_error = pcall(M.lint, linter, opts)
    if ok then
      running_procs[linter.name] = handle_or_error
    elseif not opts.ignore_errors then
      notify(handle_or_error --[[@as string]], vim.log.levels.WARN)
    end
  end
  running_procs_by_buf[bufnr] = running_procs
end

local function eval_fn_or_id(x)
  if type(x) == 'function' then
    return x()
  else
    return x
  end
end


---@param linter lint.Linter
---@param opts? {cwd?: string, ignore_errors?: boolean}
---@return uv.uv_process_t|nil
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
  opts = opts or {}
  if linter.args then
    vim.list_extend(args, vim.tbl_map(eval_fn_or_id, linter.args))
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
    cwd = opts.cwd or linter.cwd or vim.fn.getcwd(),
    detached = false
  }
  local cmd = eval_fn_or_id(linter.cmd)
  assert(cmd, 'Linter definition must have a `cmd` set: ' .. vim.inspect(linter))
  handle, pid_or_err = uv.spawn(cmd, linter_opts, function(code)
    if handle and not handle:is_closing() then
      local procs = (running_procs_by_buf[bufnr] or {})
      -- Only cleanup if there has not been another procs in between
      if handle == procs[linter.name] then
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
  local parser = linter.parser
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
  local ns = namespaces[linter.name]
  start_read(linter.stream, linter_opts.cwd, stdout, stderr, bufnr, parser, ns)
  if linter.stdin then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
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
  return handle
end


return M
