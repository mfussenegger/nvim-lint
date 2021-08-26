return function()
  local compiler = require('lint.linters.compiler')
  local linter = compiler()
  linter.stream = 'stdout'
  return linter
end
