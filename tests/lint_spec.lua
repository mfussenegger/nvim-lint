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


  it("get_running returns running linter", function()
    local linter = {
      name = "dummy",
      cmd = "python",
      args = {"tests/loop.py"},
      parser = require("lint.parser").from_errorformat("%f:%l: %m")
    }
    lint.linters.dummy = linter
    local orig_lint = lint.lint
    ---@type lint.LintProc
    local captured_proc
    ---@diagnostic disable-next-line: duplicate-set-field
    lint.lint = function(...)
      captured_proc = assert(orig_lint(...))
      return captured_proc
    end
    lint.try_lint("dummy")
    assert.are.same({"dummy"}, lint.get_running())

    assert(captured_proc)
    captured_proc:cancel()

    vim.wait(500, function() return #lint.get_running() == 0 end)
    assert.are.same({}, lint.get_running())
    assert.is_false(captured_proc.handle:is_active())
  end)
end)
