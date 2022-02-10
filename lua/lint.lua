local uv = vim.loop
local api = vim.api
local M = {}


M.linters = setmetatable({}, {
  __index = function(tbl, key)
    local ok, linter = pcall(require, 'lint.linters.' .. key)
    if ok then
      rawset(tbl, key, linter)
    end
    return linter
  end,
})


M.linters_by_ft = {
  text = {'vale',},
  markdown = {'vale',},
  rst = {'vale',},
  ruby = {'ruby',},
  inko = {'inko',},
  clojure = {'clj-kondo',},
  dockerfile = {'hadolint',},
}

local namespaces = setmetatable({}, {
  __index = function(tbl, key)
    local ns = api.nvim_create_namespace(key)
    rawset(tbl, key, ns)
    return ns
  end
})


local function read_output(bufnr, parser, publish_fn)
  return function(err, chunk)
    assert(not err, err)
    if chunk then
      parser.on_chunk(chunk, bufnr)
    else
      parser.on_done(publish_fn, bufnr)
    end
  end
end


local function start_read(stream, stdout, stderr, bufnr, parser, ns)
  local publish = function(diagnostics)
    -- By the time the linter is finished the user might have deleted the buffer
    if api.nvim_buf_is_valid(bufnr) then
      vim.diagnostic.set(ns, bufnr, diagnostics)
    end
  end
  if not stream or stream == 'stdout' then
    stdout:read_start(read_output(bufnr, parser, publish))
  elseif stream == 'stderr' then
    stderr:read_start(read_output(bufnr, parser, publish))
  elseif stream == 'both' then
    local parser1, parser2 = require('lint.parser').split(parser)
    stdout:read_start(read_output(bufnr, parser1, publish))
    stderr:read_start(read_output(bufnr, parser2, publish))
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


function M.try_lint(names)
  assert(
    vim.diagnostic,
    "nvim-lint requires neovim 0.6.0+. If you're using an older version, use the `nvim-05` tag of nvim-lint'"
  )
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
  local linters = vim.tbl_map(lookup_linter, names)
  for _, linter in pairs(linters) do
    local ok, err = pcall(M.lint, linter)
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
end


local function eval_fn_or_id(x)
  if type(x) == 'function' then
    return x()
  else
    return x
  end
end


function M.lint(linter)
  assert(linter, 'lint must be called with a linter')
  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local handle
  local env
  local pid_or_err
  local args = {}
  local bufnr = api.nvim_get_current_buf()
  if linter.args then
    vim.list_extend(args, vim.tbl_map(eval_fn_or_id, linter.args))
  end
  if not linter.stdin and linter.append_fname ~= false then
    table.insert(args, api.nvim_buf_get_name(bufnr))
  end
  if linter.env then
    if not linter.env["PATH"] then
      -- Always include PATH as we need it to execute the linter command
      env = {"PATH=" .. os.getenv("PATH")}
    end
    for k, v in pairs(linter.env) do
      table.insert(env, k .. "=" .. v)
    end
  end
  local opts = {
    args = args,
    stdio = {stdin, stdout, stderr},
    env = env,
    cwd = vim.fn.getcwd(),
    detached = false
  }
  local cmd = eval_fn_or_id(linter.cmd)
  assert(cmd, 'Linter definition must have a `cmd` set: ' .. vim.inspect(linter))
  handle, pid_or_err = uv.spawn(cmd, opts, function(code)
    stdout:close()
    stderr:close()
    handle:close()
    if code ~= 0 and not linter.ignore_exitcode then
      print('Linter command', cmd, 'exited with code', code)
    end
  end)
  assert(handle, 'Error running ' .. cmd .. ': ' .. pid_or_err)
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
  start_read(linter.stream, stdout, stderr, bufnr, parser, ns)
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
end


return M
