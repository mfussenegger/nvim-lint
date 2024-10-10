local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = "3.0"
package = 'nvim-lint'
version = _MODREV .. _SPECREV
description = {
  summary = 'An asynchronous linter plugin for Neovim ',
  detailed = [[
  nvim-lint runs linters, parses their output, and reports the results via the
  vim.diagnostic module.
  ]],
  labels = {
    'neovim',
    'plugin',
    'linter',
  },
  homepage = 'https://github.com/mfussenegger/nvim-lint',
  license = 'GPL-3.0',
}
dependencies = {
  'lua >= 5.1, <= 5.4',
}
test_dependencies = {
  "nlua",
}
source = {
   url = 'git://github.com/mfussenegger/nvim-lint',
}
build = {
   type = 'builtin',
   copy_directories = {
     'doc',
   },
}
