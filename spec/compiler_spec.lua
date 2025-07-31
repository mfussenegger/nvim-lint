local function get_num_handles()
  local pid = vim.fn.getpid()
  local output = vim.fn.system({"lsof", "-p"}, tostring(pid))
  local lines = vim.split(output, "\n", { plain = true })
  return #lines
end

describe('compiler', function()
  it('reads errors from both stdout and stderr', function()
    local a = vim.api
    local bufnr = a.nvim_create_buf(true, true)
    a.nvim_buf_set_name(bufnr, "spec/both.py")
    a.nvim_set_current_buf(bufnr)
    a.nvim_buf_set_option(bufnr, 'errorformat', '%f:%l: %m')
    a.nvim_buf_set_option(bufnr, 'makeprg', 'python spec/both.py')

    local handles = get_num_handles()
    require('lint').try_lint('compiler')

    vim.wait(5000, function() return next(vim.diagnostic.get(bufnr)) ~= nil end)

    assert.are.same(handles, get_num_handles(), "shouldn't leak any handles")

    local result = vim.diagnostic.get(bufnr)
    for _, d in pairs(result) do
      d.namespace = nil
      d._extmark_id = nil
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
