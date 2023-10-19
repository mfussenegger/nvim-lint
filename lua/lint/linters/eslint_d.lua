local binary_name = "eslint_d"
return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. binary_name, ':p')
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  args = {
    '--format',
    'json',
    '--stdin',
    '--stdin-filename',
    function() return vim.api.nvim_buf_get_name(0) end,
  },
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local result = require("lint.linters.eslint").parser(output, bufnr)
    for _, d in ipairs(result) do
      d.source = binary_name
    end
    return result
  end
})
