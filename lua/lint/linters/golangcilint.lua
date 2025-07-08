local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

-- Gets the correct arguments to run based on the version of golangci-lint
local getArgs = function()
  local ok, version_info = pcall(vim.fn.system, { 'golangci-lint', 'version' })
  if not ok then
    return
  end

  -- Handle editing a standalone golang file that isn't apart of a normal setup where
  -- the go.mod file can't be found by golangci-lint. In this situation, we need to provide
  -- the current buffer path to golangci-lint instead of it's parent directory to allow
  -- the buffer content to be linted, otherwise golangci-lint will raise an error
  local ok, go_mod_location = pcall(vim.fn.system, { 'go', 'env', "GOMOD" })
  if not ok then
    return
  end
  local filename_modifier = ":h"
  -- No go.mod file was found, so just lint the buffer directly
  if go_mod_location:gsub("%s+", "") == "/dev/null" then
    filename_modifier = ":p"
  end

  -- The golangci-lint install script and prebuilt binaries strip the v from the version
  --   tag so both strings must be checked
  if string.find(version_info, 'version v1') or string.find(version_info, 'version 1') then
    return {
      'run',
      '--out-format',
      'json',
      '--issues-exit-code=0',
      '--show-stats=false',
      '--print-issued-lines=false',
      '--print-linter-name=false',
      function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), filename_modifier)
      end
    }
  end

  -- Omit --path-mode=abs, as it was added on v2.1.0
  -- Make sure it won't break v2.0.{0,1,2}
  if string.find(version_info, 'version v2.0.') or string.find(version_info, 'version 2.0.') then
    -- If the linter is not working as expected, users should explicitly add
    -- `run.relative-path-mode: wd` to their .golangci.yaml as a workaround to preserve the previous behavior.
    -- Prior to v2.0.0, the default for `run.relative-path-mode` was "wd".
    -- See: https://golangci-lint.run/product/migration-guide/#runrelative-path-mode

    return {
      'run',
      '--output.json.path=stdout',
      -- Overwrite values possibly set in .golangci.yml
      '--output.text.path=',
      '--output.tab.path=',
      '--output.html.path=',
      '--output.checkstyle.path=',
      '--output.code-climate.path=',
      '--output.junit-xml.path=',
      '--output.teamcity.path=',
      '--output.sarif.path=',
      '--issues-exit-code=0',
      '--show-stats=false',
      function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), filename_modifier)
      end,
    }
  end

  return {
    'run',
    '--output.json.path=stdout',
    -- Overwrite values possibly set in .golangci.yml
    '--output.text.path=',
    '--output.tab.path=',
    '--output.html.path=',
    '--output.checkstyle.path=',
    '--output.code-climate.path=',
    '--output.junit-xml.path=',
    '--output.teamcity.path=',
    '--output.sarif.path=',
    '--issues-exit-code=0',
    '--show-stats=false',
    -- Get absolute path of the linted file
    '--path-mode=abs',
    function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), filename_modifier)
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

      if curfile_norm == item.Pos.Filename or curfile_norm == lintedfile_norm then
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
