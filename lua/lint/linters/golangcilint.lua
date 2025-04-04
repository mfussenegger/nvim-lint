local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

local find_go_mod_dir = function(start_dir)
  local dir = start_dir or vim.fn.getcwd()
  local parent = dir

  while true do
    local go_mod_path = parent .. '/go.mod'
    local file = io.open(go_mod_path, 'r')
    if file then
      file:close()
      return parent
    end
    local next_parent = vim.fn.fnamemodify(parent, ':h')
    if next_parent == parent then
      return nil -- reached filesystem root without finding go.mod
    end
    parent = next_parent
  end
end

-- Gets the correct agruements to run based on the version of golangci-lint
local getArgs = function()
  local ok, output = pcall(vim.fn.system, { 'golangci-lint', 'version' })
  if not ok then
    return
  end

  -- The golangci-lint install script and prebuilt binaries strip the v from the version
  --   tag so both strings must be checked
  if string.find(output, 'version v1') or string.find(output, 'version 1') then
    return {
      'run',
      '--out-format',
      'json',
      '--issues-exit-code=0',
      '--show-stats=false',
      '--print-issued-lines=false',
      '--print-linter-name=false',
      function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      end
    }
  end

  return {
    'run',
    '--output.json.path=stdout',
    '--issues-exit-code=0',
    '--show-stats=false',
    function()
      return find_go_mod_dir(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')) .. '/...'
    end,
  }
end

return {
  cmd = 'golangci-lint',
  append_fname = false,
  args = getArgs(),
  stream = 'stdout',
  parser = function(output, bufnr, cwd)
    if output == '' then
      return {}
    end
    local decoded = vim.json.decode(output)
    if decoded["Issues"] == nil or type(decoded["Issues"]) == 'userdata' then
      return {}
    end

    local diagnostics = {}
    for _, item in ipairs(decoded["Issues"]) do
      local curfile = vim.api.nvim_buf_get_name(bufnr)
      local curfile_abs = vim.fn.fnamemodify(curfile, ":p")
      local curfile_norm = vim.fs.normalize(curfile_abs)

      local lintedfile = cwd .. "/" .. item.Pos.Filename
      local lintedfile_abs = vim.fn.fnamemodify(lintedfile, ":p")
      local lintedfile_norm = vim.fs.normalize(lintedfile_abs)

      if curfile_norm == lintedfile_norm then
        -- only publish if those are the current file diagnostics
        local sv = severities[item.Severity] or severities.warning
        table.insert(diagnostics, {
          lnum = item.Pos.Line > 0 and item.Pos.Line - 1 or 0,
          col = item.Pos.Column > 0 and item.Pos.Column - 1 or 0,
          end_lnum = item.Pos.Line > 0 and item.Pos.Line - 1 or 0,
          end_col = item.Pos.Column > 0 and item.Pos.Column - 1 or 0,
          severity = sv,
          source = item.FromLinter,
          message = item.Text,
        })
      end
    end
    return diagnostics
  end
}
