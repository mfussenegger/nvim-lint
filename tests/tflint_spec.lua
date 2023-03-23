describe('linter.tflint', function()
  it('Parses output sample', function()
    local parser = require('lint.linters.tflint').parser
    local bufnr = vim.uri_to_bufnr('file:///main.tf')
    local result = parser(
      [[{"issues":[{"rule":{"name":"terraform_required_providers","severity":"warning","link":"https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.2.2/docs/rules/terraform_required_providers.md"},"message":"Missing version constraint for provider \"aws\" in \"required_providers\"","range":{"filename":"/main.tf","start":{"line":19,"column":1},"end":{"line":19,"column":15}},"callers":[]}],"errors":[]}]],
      bufnr)
    assert.are.same(1, #result)
    local expected = {
      source = 'tflint',
      message = 'Missing version constraint for provider "aws" in "required_providers" (terraform_required_providers)\nReference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.2.2/docs/rules/terraform_required_providers.md',
      lnum = 19,
      col = 1,
      end_lnum = 19,
      end_col = 15,
      severity = vim.diagnostic.severity.WARN,
    }

    assert.are.same(expected, result[1])
  end)
end)
