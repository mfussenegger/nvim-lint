describe('linter.ruby', function()
  it('can parse the output', function()
    local parser = require('lint.linters.ruby').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.rb')
    local output = [[
/foo.rb:2: warning: key :bar is duplicated and overwritten on line 2
/foo.rb:2: warning: unused literal ignored
/foo.rb:3: syntax error, unexpected end-of-input
]]
    local result = parser(output, bufnr)

    assert.are.same(3, #result)

    local expected_warning_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 1,
      lnum = 1,
      message = 'key :bar is duplicated and overwritten on line 2',
      severity = 2,
      source = 'ruby',
    }

    assert.are.same(expected_warning_1, result[1])

    local expected_warning_2 = {
      col = 0,
      end_col = 0,
      end_lnum = 1,
      lnum = 1,
      message = 'unused literal ignored',
      severity = 2,
      source = 'ruby',
    }

    assert.are.same(expected_warning_2, result[2])

    local expected_error_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 2,
      lnum = 2,
      message = 'unexpected end-of-input',
      severity = 1,
      source = 'ruby',
    }

    assert.are.same(expected_error_1, result[3])
  end)
end)
