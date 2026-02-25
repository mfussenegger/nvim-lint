describe("linter.trivy_secret", function()
  it("Parses output sample", function()
    local parser = require("lint.linters.trivy_secret").parser
    local bufnr = vim.uri_to_bufnr("file:///ingress.yaml")
    local output = [[
{
  "SchemaVersion": 2,
  "CreatedAt": "2025-05-14T00:38:06.703758502+03:00",
  "ArtifactName": "ingress.yaml",
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
      "Target": "ingress.yaml",
      "Class": "secret",
      "Secrets": [
        {
          "RuleID": "private-key",
          "Category": "AsymmetricPrivateKey",
          "Severity": "HIGH",
          "Title": "Asymmetric Private Key",
          "StartLine": 3,
          "EndLine": 3,
          "Code": {
            "Lines": [
              {
                "Number": 1,
                "Content": "---",
                "IsCause": false,
                "Annotation": "",
                "Truncated": false,
                "Highlighted": "---",
                "FirstCause": false,
                "LastCause": false
              },
              {
                "Number": 2,
                "Content": "key: |",
                "IsCause": false,
                "Annotation": "",
                "Truncated": false,
                "Highlighted": "key: |",
                "FirstCause": false,
                "LastCause": false
              },
              {
                "Number": 3,
                "Content": "  -----BEGIN PRIVATE KEY-----**************-----END PRIVATE KEY-----",
                "IsCause": true,
                "Annotation": "",
                "Truncated": false,
                "Highlighted": "  -----BEGIN PRIVATE KEY-----**************-----END PRIVATE KEY-----",
                "FirstCause": true,
                "LastCause": true
              },
              {
                "Number": 4,
                "Content": "",
                "IsCause": false,
                "Annotation": "",
                "Truncated": false,
                "FirstCause": false,
                "LastCause": false
              }
            ]
          },
          "Match": "  -----BEGIN PRIVATE KEY-----**************-----END PRIVATE KEY-----",
          "Layer": {}
        }
      ]
    }
  ]
}
    ]]
    local result = parser(output, bufnr)
    local expected = {
      {
        source = "trivy_secret",
        message = "Asymmetric Private Key",
        lnum = 2,
        end_lnum = 2,
        col = 0,
        end_col = 0,
        severity = vim.diagnostic.severity.ERROR,
        code = "private-key",
      },
    }
    assert.are.same(expected, result)
  end)
end)
