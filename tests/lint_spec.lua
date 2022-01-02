describe('lint', function()
  local a = vim.api
  local bufnr = a.nvim_create_buf(true, true)
  a.nvim_buf_set_option(bufnr, 'filetype', 'ansible.yaml')
  local lint = require('lint')

  it('resolves all linters for compound filetypes', function()
    lint.linters_by_ft = {
      ansible = {'ansible-lint'},
      yaml = {'yamllint'},
    }
    local names = lint._resolve_linter_by_ft('ansible.yaml')
    local expected = {'ansible-lint', 'yamllint'}
    table.sort(names, function(x, y) return x < y end)
    assert.are.same(expected, names)
  end)
  it('deduplicates linters for compound filetypes', function()
    lint.linters_by_ft = {
      ansible = {'ansible-lint','yamllint'},
      yaml = {'yamllint'},
    }
    local names = lint._resolve_linter_by_ft('ansible.yaml')
    local expected = {'ansible-lint', 'yamllint'}
    table.sort(names, function(x, y) return x < y end)
    assert.are.same(expected, names)
  end)
end)

