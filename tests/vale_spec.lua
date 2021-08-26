describe('linter.vale', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.vale').parser
    parser('')
    parser('  ')
  end)
end)

