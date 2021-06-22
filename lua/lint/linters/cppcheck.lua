local cppcheck_pattern = [[([^:]*):(%d*):(%d*): %[([^%]\]*)%] ([^:]*): (.*)]]
return {
  cmd = 'cppcheck',
  stdin = false,
  args = {
    '--enable=warning,style,performance,information', '--language=c++',
    '--project=build/compile_commands.json', '--inline-suppr', '--quiet',
    '--cppcheck-build-dir=build', '--template={file}:{line}:{column}: [{id}] {severity}: {message}'
  },
  stream = 'stderr',
  parser = function(output, bufnr)
    local buffer_path = vim.api.nvim_buf_get_name(bufnr)
    local diagnostics = {}
    for line in vim.gsplit(output, '\n') do
      for file, lineno, colno, id, severity, msg in string.gmatch(line, cppcheck_pattern) do
        if file == buffer_path then
          local diagnostic = {}
          diagnostic.range = {}
          local line_num = tonumber(lineno)
          local col_num = tonumber(colno)
          local range = {line = line_num - 1, character = col_num - 1}
          diagnostic.range.start = range
          diagnostic.range['end'] = range
          if severity == 'style' or severity == 'information' then
            diagnostic.severity = vim.lsp.protocol.DiagnosticSeverity.Information
          elseif severity == 'warning' or severity == 'performance' then
            diagnostic.severity = vim.lsp.protocol.DiagnosticSeverity.Warning
          elseif severity == 'error' then
            diagnostic.severity = vim.lsp.protocol.DiagnosticSeverity.Error
          end

          diagnostic.source = 'cppcheck(' .. id .. ')'
          diagnostic.message = msg
          diagnostics[#diagnostics + 1] = diagnostic
        end
      end
    end

    return diagnostics
  end
}
