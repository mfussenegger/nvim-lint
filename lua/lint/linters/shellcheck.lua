local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  style = vim.diagnostic.severity.HINT,
}

-- In order to resolve the special path `SCRIPTDIR` in shellcheck's
-- `source-path` directive it is necessary to pass the source as a filename
-- rather than to stdin. To still be able to lint unnamed buffers we specify
-- `stdin = true` and `-` as the filename as fallback. This works because
-- shellcheck ignores stdin input when there are filenames in the argument
-- list. This workaround could be removed when/if shellcheck implements
-- --stdin-filename, see https://github.com/koalaman/shellcheck/issues/2735.
local function filename_or_stdin()
  local bufname = vim.api.nvim_buf_get_name(0)
  local file = vim.fn.fnameescape(vim.fn.fnamemodify(bufname, ':p'))
  if vim.bo.buftype == '' and vim.fn.filereadable(file) == 1 then
    return file
  end
  return '-'
end


return {
  cmd = 'shellcheck',
  stdin = true,
  args = {
    '--format', 'json1',
    filename_or_stdin,
  },
  ignore_exitcode = true,
  parser = function(output)
    if output == "" then return {} end
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded.comments or {}) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        col = item.column - 1,
        end_lnum = item.endLine - 1,
        end_col = item.endColumn - 1,
        code = item.code,
        source = "shellcheck",
        user_data = {
          lsp = {
            code = item.code,
          },
        },
        severity = assert(severities[item.level], 'missing mapping for severity ' .. item.level),
        message = item.message,
      })
    end
    return diagnostics
  end,
}
