describe('compiler', function()
  it('reads errors from both stdout and stderr', function()
    local a = vim.api
    local bufnr = a.nvim_create_buf(true, true)
    a.nvim_set_current_buf(bufnr)
    a.nvim_buf_set_option(bufnr, 'errorformat', '%l: %m')
    a.nvim_buf_set_option(bufnr, 'makeprg', '/usr/bin/python tests/both.py')

    local result = nil
    vim.lsp.handlers['textDocument/publishDiagnostics'] = function(_, diagnostics)
      result = diagnostics
    end
    require('lint').try_lint('compiler')

    vim.wait(5000, function() return result ~= nil end)
    local expected = {
      {
        message = 'foo',
        range = {
          start = { line = 9, character = 0, },
          ['end'] = { line = 9, character = 0 },
        },
        severity = 1,
      },
      {
        message = 'bar',
        range = {
          start = { line = 19, character = 0, },
          ['end'] = { line = 19, character = 0 },
        },
        severity = 1,
      },
    }
    assert.are.same(expected, result.diagnostics)
  end)
end)
