return {
  cmd = 'nilaway',
  stdin = false,
  append_fname = true,
  args = { '-pretty-print=false', '-json' },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}

    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end

    local cmdLineArgs = decoded['command-line-arguments']
    if not cmdLineArgs then
      return diagnostics
    end

    local nilaway = cmdLineArgs.nilaway
    if not nilaway then
      return diagnostics
    end

    for _, diagnostic in ipairs(nilaway) do
      local pos = diagnostic.posn
      if not pos then
        goto continue
      end

      local parts = vim.split(pos, ':')
      if #parts < 3 then
        goto continue
      end

      local l = tonumber(parts[2])
      local c = tonumber(parts[3])
      if not l or not c then
        goto continue
      end

      table.insert(diagnostics, {
        lnum = l - 1,
        col = c - 1,
        message = diagnostic.message,
        severity = vim.diagnostic.severity.WARN
      })

      ::continue::
    end

    return diagnostics
  end
}
