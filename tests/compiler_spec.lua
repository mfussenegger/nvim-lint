describe('compiler', function()
  it('reads errors from both stdout and stderr', function()
    local a = vim.api
    local bufnr = a.nvim_create_buf(true, true)
    a.nvim_set_current_buf(bufnr)
    a.nvim_buf_set_option(bufnr, 'errorformat', '%l: %m')
    a.nvim_buf_set_option(bufnr, 'makeprg', 'python tests/both.py')

    require('lint').try_lint('compiler')

    vim.wait(5000, function() return next(vim.diagnostic.get(bufnr)) ~= nil end)
    local result = vim.diagnostic.get(bufnr)
    for _, d in pairs(result) do
      d.namespace = nil
    end
    local expected = {
      {
        bufnr = bufnr,
        col = 0,
        end_col = 0,
        lnum = 9,
        end_lnum = 9,
        message = 'foo',
        severity = 1,
      },
      {
        bufnr = bufnr,
        col = 0,
        end_col = 0,
        end_lnum = 19,
        lnum = 19,
        message = 'bar',
        severity = 1,
      },
    }
    assert.are.same(expected, result)
  end)
end)
