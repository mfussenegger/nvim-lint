describe("linter.trivy", function()
  it("Parses output sample", function()
    local parser = require("lint.linters.trivy").parser
    local bufnr = vim.uri_to_bufnr("file:///main.tf")
    local output = [[
{
  "SchemaVersion": 2,
  "ArtifactName": "main.tf",
  "ArtifactType": "filesystem",
  "Metadata": {
    "ImageConfig": {
      "architecture": "",
      "created": "0001-01-01T00:00:00Z",
      "os": "",
      "rootfs": {
        "type": "",
        "diff_ids": null
      },
      "config": {}
    }
  },
  "Results": [
    {
      "Target": ".",
      "Class": "config",
      "Type": "terraform",
      "MisconfSummary": {
        "Successes": 1,
        "Failures": 0,
        "Exceptions": 0
      }
    },
    {
      "Target": "main.tf",
      "Class": "config",
      "Type": "terraform",
      "MisconfSummary": {
        "Successes": 0,
        "Failures": 1,
        "Exceptions": 0
      },
      "Misconfigurations": [
        {
          "Type": "Terraform Security Check",
          "ID": "AVD-AWS-0065",
          "AVDID": "AVD-AWS-0065",
          "Title": "A KMS key is not configured to auto-rotate.",
          "Description": "You should configure your KMS keys to auto rotate to maintain security and defend against compromise.",
          "Message": "Key does not have rotation enabled.",
          "Query": "data..",
          "Resolution": "Configure KMS key to auto rotate",
          "Severity": "MEDIUM",
          "PrimaryURL": "https://avd.aquasec.com/misconfig/avd-aws-0065",
          "References": [
            "https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html",
            "https://avd.aquasec.com/misconfig/avd-aws-0065"
          ],
          "Status": "FAIL",
          "Layer": {},
          "CauseMetadata": {
            "Resource": "aws_kms_key.foo",
            "Provider": "AWS",
            "Service": "kms",
            "StartLine": 15,
            "EndLine": 15,
            "Code": {
              "Lines": [
                {
                  "Number": 15,
                  "Content": "resource \"aws_kms_key\" \"foo\" {}",
                  "IsCause": true,
                  "Annotation": "",
                  "Truncated": false,
                  "FirstCause": true,
                  "LastCause": true
                }
              ]
            }
          }
        }
      ]
    }
  ]
}
    ]]
    local result = parser(output, bufnr)
    local expected = {
      {
        source = "trivy",
        message = "A KMS key is not configured to auto-rotate. You should configure your KMS keys to auto rotate to maintain security and defend against compromise.",
        lnum = 14,
        end_lnum = 14,
        col = 15,
        end_col = 15,
        severity = vim.diagnostic.severity.WARN,
        code = "AVD-AWS-0065",
      },
    }
    assert.are.same(expected, result)
  end)
end)
