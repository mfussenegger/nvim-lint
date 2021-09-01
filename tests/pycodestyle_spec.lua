describe('linter.pycodestyle', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.pycodestyle').parser
    parser('')
    parser('  ')
  end)
end)
