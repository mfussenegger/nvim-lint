local uv = vim.loop
local api = vim.api
local M = {}
local CLIENT_ID = 173  -- arbitrary value that is large enough to not conflict with real clients


M.linters = setmetatable({}, {
  __index = function(tbl, key)
    local ok, linter = pcall(require, 'lint.linters.' .. key)
    if ok then
      rawset(tbl, key, linter)
    end
    return linter
  end,
})


M.linter_by_ft = {
  text = 'languagetool',
  markdown = 'languagetool',
}


local function resolve_linter()
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  local linter_name = M.linter_by_ft[ft]
  assert(linter_name, 'No linter registered for filetype ' .. ft)
  local linter = M.linters[linter_name]
  assert(linter, 'Linter with name `' .. linter_name .. '` is not available')
  return linter
end


local function mk_publish_diagnostics(bufnr)
  local method = 'textDocument/publishDiagnostics'
  return vim.schedule_wrap(function(diagnostics)
    local result = {
      uri = vim.uri_from_bufnr(bufnr),
      diagnostics = diagnostics,
    }
    vim.lsp.handlers[method](nil, method, result, CLIENT_ID, bufnr)
  end)
end


local function read_output(bufnr, parser)
  return function(err, chunk)
    assert(not err, err)
    if chunk then
      parser.on_chunk(bufnr, chunk)
    else
      parser.on_done(bufnr, mk_publish_diagnostics(bufnr))
    end
  end
end


function M.lint(linter)
  linter = linter or resolve_linter()
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local handle
  local pid_or_err
  local args = {}
  local bufnr = api.nvim_get_current_buf()
  vim.list_extend(args, linter.args)
  table.insert(args, api.nvim_buf_get_name(bufnr))
  local opts = {
    args = args,
    stdio = {stdout, stderr},
    cwd = vim.fn.getcwd(),
    detached = true
  }
  handle, pid_or_err = uv.spawn(linter.cmd, opts, function(code)
    stdout:close()
    stderr:close()
    handle:close()
    if code ~= 0 then
      print('Linter exited with code', code)
    end
  end)
  assert(handle, 'Error running ' .. linter.cmd .. ': ' .. pid_or_err)
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
  if parser.stream == 'stdout' then
    stdout:read_start(read_output(bufnr, parser))
  else
    stderr:read_start(read_output(bufnr, parser))
  end
end


return M
