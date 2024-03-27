local severities = {}
severities[1] = vim.diagnostic.severity.ERROR
severities[2] = vim.diagnostic.severity.WARN
severities[3] = vim.diagnostic.severity.INFO
severities[4] = vim.diagnostic.severity.HINT
severities[5] = vim.diagnostic.severity.HINT

local bin = 'phpmd'
return {
  cmd = function ()
    local local_bin = vim.fn.fnamemodify('vendor/bin/' .. bin, ':p')
    return vim.loop.fs_stat(local_bin) and local_bin or bin
  end,
  stdin = true,
  args = {
    '-',
    'json',
    'cleancode,codesize,controversial,design,naming,unusedcode',
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output, _)

    if vim.trim(output) == '' or output == nil then
      return {}
    end

    if not vim.startswith(output, '{') then
      vim.notify(output)
      return {}
    end

    local decoded = vim.json.decode(output)
    local diagnostics = {}
    local messages = {}

    if decoded['files'] and decoded['files'][1] and decoded['files'][1]['violations'] then
      messages = decoded['files'][1]['violations']
    end

    for _, msg in ipairs(messages or {}) do
      table.insert(diagnostics, {
        lnum = msg.beginLine - 1,
        end_lnum = msg.endLine - 1,
        col = 0,
        end_col = 0,
        message = msg.description,
        code = msg.rule,
        source = bin,
        severity = assert(severities[msg.priority], 'missing mapping for severity ' .. msg.priority),
      })
    end

    return diagnostics
  end
}
