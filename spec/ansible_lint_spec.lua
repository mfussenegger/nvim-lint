describe('linter.ansible_lint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.ansible_lint').parser
    local result = parser([[
WARNING  Listing 4 violation(s) that are fatal
playbooks/roles/vim/tasks/common.yml:14: git-latest Git checkouts must contain explicit version
playbooks/roles/vim/tasks/common.yml:39: git-latest Git checkouts must contain explicit version
playbooks/roles/vim/tasks/common.yml:52: git-latest Git checkouts must contain explicit version
playbooks/roles/vim/tasks/common.yml:65: no-changed-when Commands should not change things if nothing needs doing
You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - git-latest  # Git checkouts must contain explicit version
  - no-changed-when  # Commands should not change things if nothing needs doing

Finished with 4 failure(s), 0 warning(s) on 1 files.
]])
  assert.are.same(4, #result)
  local expected = {
    source = 'ansible-lint',
    message = 'git-latest Git checkouts must contain explicit version',
    lnum = 13,
    col = 0,
    end_lnum = 13,
    end_col = 0,
    severity = vim.diagnostic.severity.INFO,
  }
  assert.are.same(expected, result[1])
  end)
end)
