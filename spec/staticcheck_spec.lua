describe('linter.staticcheck', function()
  it('can parse the output', function()
    local parser = require('lint.linters.staticcheck').parser
    local bufnr = vim.uri_to_bufnr('file:///main.go')
    local result = parser([[
{"code":"S1001","severity":"error","location":{"file":"/main.go","line":8,"column":2},"end":{"file":"/main.go","line":8,"column":23},"message":"should use copy() instead of a loop"}
{"code":"S1002","severity":"error","location":{"file":"/main.go","line":13,"column":5},"end":{"file":"/main.go","line":13,"column":14},"message":"should omit comparison to bool constant, can be simplified to x"}
{"code":"S1002","severity":"error","location":{"file":"/sub.go","line":7,"column":5},"end":{"file":"/sub.go","line":7,"column":14},"message":"should omit comparison to bool constant, can be simplified to y"}
]], bufnr)

    assert.are.same(2, #result)

    local expected_error_1 = {
      code = 'S1001',
      col = 1,
      end_col = 22,
      end_lnum = 7,
      lnum = 7,
      message = 'should use copy() instead of a loop',
      severity = 1,
      user_data = {
        lsp = {
          code = 'S1001'
        }
      }
    }

    assert.are.same(expected_error_1, result[1])

    local expected_error_2 = {
      code = 'S1002',
      col = 4,
      end_col = 13,
      end_lnum = 12,
      lnum = 12,
      message = 'should omit comparison to bool constant, can be simplified to x',
      severity = 1,
      user_data = {
        lsp = {
          code = 'S1002'
        }
      }
    }

    assert.are.same(expected_error_2, result[2])
  end)
end)
