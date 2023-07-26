describe('linter.tfsec', function()
  it('Parses output sample', function()
    local parser = require('lint.linters.tfsec').parser
    local bufnr = vim.uri_to_bufnr('file:///main.tf')
    local output = [[
      {
        "results": [
          {
            "rule_id": "AVD-AWS-0065",
            "long_id": "aws-kms-auto-rotate-keys",
            "rule_description": "A KMS key is not configured to auto-rotate.",
            "rule_provider": "aws",
            "rule_service": "kms",
            "impact": "Long life KMS keys increase the attack surface when compromised",
            "resolution": "Configure KMS key to auto rotate",
            "links": [
              "https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/kms/auto-rotate-keys/",
              "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#enable_key_rotation"
            ],
            "description": "Key does not have rotation enabled.",
            "severity": "MEDIUM",
            "warning": false,
            "status": 0,
            "resource": "aws_kms_key.key",
            "location": {
              "filename": "/main.tf",
              "start_line": 1,
              "end_line": 4
            }
          }
        ]
      }
    ]]
    local result = parser(output, bufnr)
    local expected = {
      {
        source = 'tfsec',
        message = "Key does not have rotation enabled. Long life KMS keys increase the attack surface when compromised",
        lnum = 0,
        end_lnum = 3,
        col = 1,
        end_col = 4,
        severity = vim.diagnostic.severity.WARN,
        code = "AVD-AWS-0065",
      }
    }
    assert.are.same(expected, result)
  end)
end)
