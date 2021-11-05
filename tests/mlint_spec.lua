describe('linter.mlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.mlint').parser
    local result = parser([[
L 1 (C 1): SCABE: ML5: The McCabe cyclomatic complexity is 2.
L 1 (C 7-9): CLALL: ML0: Using 'clear' with the 'all' option usually decreases code performance and is often unnecessary.
L 7 (C 18): ACABE: ML5: The McCabe cyclomatic complexity of the anonymous function on line 7 is 1.
L 10 (C 48-51): SYNER: ML3: Parse error at recs: usage might be invalid MATLAB syntax.
L 13 (C 1-3): RESWD: ML3: Invalid use of a reserved word.
]])
  assert.are.same(5, #result)

  local expected = {
    source = 'mlint',
    message = 'The McCabe cyclomatic complexity is 2.',
    code = 'SCABE',
    severity = vim.lsp.protocol.DiagnosticSeverity.Hint,
    range = {
      ['start'] = {
        character = 0,
        line = 0,
      },
      ['end'] = {
        character = 1,
        line = 0,
      }
    },
  }
  assert.are.same(expected, result[1])

  expected = {
    source = 'mlint',
    message = 'Parse error at recs: usage might be invalid MATLAB syntax.',
    code = 'SYNER',
    severity = vim.lsp.protocol.DiagnosticSeverity.Error,
    range = {
      ['start'] = {
        character = 47,
        line = 9,
      },
      ['end'] = {
        character = 51,
        line = 9,
      }
    },
  }
  assert.are.same(expected, result[4])
end)
end)
