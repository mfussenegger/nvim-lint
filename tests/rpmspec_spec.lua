describe('linter.rpmspec', function()
  it('can parse the output', function()
    local parser = require('lint.linters.rpmspec').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.spec')
    local output = [[
warning: Macro expanded in comment on line 1: %{?fedora}
error: line 2: Unknown tag: %if
]]
    local result = parser(output, bufnr)
    assert.are.same(2, #result)

    local expected_warning_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 0,
      lnum = 0,
      message = 'Macro expanded in comment',
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmspec',
    }
    local expected_error_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 1,
      lnum = 1,
      message = 'Unknown tag: %if',
      severity = vim.diagnostic.severity.ERROR,
      source = 'rpmspec',
    }
    assert.are.same(expected_error_1, result[1])
    assert.are.same(expected_warning_1, result[2])
  end)
end)
