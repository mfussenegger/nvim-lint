describe('linter.mlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.mlint').parser
    local result = parser([[
L 1 (C 1): SCABE: ML5: The McCabe cyclomatic complexity is 2.
L 1 (C 7-9): CLALL: ML0: Using 'clear' with the 'all' option usually decreases code performance and is often unnecessary.
L 7 (C 18): ACABE: ML5: The McCabe cyclomatic complexity of the anonymous function on line 7 is 1.
L 10 (C 48-51): SYNER: ML3: Parse error at recs: usage might be invalid MATLAB syntax.
L 13 (C 1-3): RESWD: ML3: Invalid use of a reserved word.
]], vim.api.nvim_get_current_buf())
  assert.are.same(5, #result)

  local expected = {
    source = 'mlint',
    message = 'The McCabe cyclomatic complexity is 2.',
    severity = vim.diagnostic.severity.HINT,
    lnum = 0,
    col = 0,
    end_lnum = 0,
    end_col = 0,
    code = 'SCABE',
    user_data = {
      lsp = {
        code = 'SCABE',
      }
    },
  }
  assert.are.same(expected, result[1])

  expected = {
    source = 'mlint',
    message = 'Parse error at recs: usage might be invalid MATLAB syntax.',
    severity = vim.diagnostic.severity.ERROR,
    lnum = 9,
    col = 47,
    end_lnum = 9,
    end_col = 50,
    code = 'SYNER',
    user_data = {
      lsp = {
        code = 'SYNER',
      },
    },
  }
  assert.are.same(expected, result[4])
end)
end)
