describe('compiler', function()
  it('reads errors from both stdout and stderr', function()
    local a = vim.api
    local bufnr = a.nvim_create_buf(true, true)
    a.nvim_set_current_buf(bufnr)
    a.nvim_buf_set_option(bufnr, 'errorformat', '%l: %m')
    a.nvim_buf_set_option(bufnr, 'makeprg', '/usr/bin/python tests/both.py')

    local result = nil
    -- this is nasty, but fine for tests
    vim.diagnostic.set = function(_, _, diagnostics)
      result = diagnostics
    end
    require('lint').try_lint('compiler')

    vim.wait(5000, function() return result ~= nil end)
    local expected = {
      {
        col = 0,
        end_col = 0,
        lnum = 9,
        end_lnum = 9,
        message = 'foo',
        severity = 1,
        user_data = {
          lsp = {
          }
        }
      },
      {
        col = 0,
        end_col = 0,
        end_lnum = 19,
        lnum = 19,
        message = 'bar',
        severity = 1,
        user_data = {
          lsp = {
          }
        }
      },
    }
    assert.are.same(expected, result)
  end)
end)
