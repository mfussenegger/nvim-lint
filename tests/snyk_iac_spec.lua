describe("linter.snyk_iac", function()
  it("Parses output sample", function()
    local parser = require("lint.linters.snyk_iac").parser
    local bufnr = vim.uri_to_bufnr("file:///main.tf")
    local output = [[
{
  "meta": {
    "isPrivate": true,
    "isLicensesEnabled": false,
    "ignoreSettings": {
      "adminOnly": true,
      "reasonRequired": true,
      "disregardFilesystemIgnores": false
    },
    "org": "",
    "orgPublicId": "",
    "policy": ""
  },
  "filesystemPolicy": false,
  "vulnerabilities": [],
  "dependencyCount": 0,
  "licensesPolicy": null,
  "ignoreSettings": null,
  "targetFile": "main.tf",
  "projectName": "example-tf",
  "org": "",
  "policy": "",
  "isPrivate": true,
  "targetFilePath": "/home/Projects/tmp/example-tf/main.tf",
  "packageManager": "terraformconfig",
  "path": "main.tf",
  "projectType": "terraformconfig",
  "ok": false,
  "infrastructureAsCodeIssues": [
    {
      "id": "SNYK-CC-TF-119",
      "title": "IAM Policy grants full administrative rights",
      "severity": "medium",
      "isIgnored": false,
      "subType": "IAM",
      "documentation": "https://security.snyk.io/rules/cloud/SNYK-CC-TF-119",
      "isGeneratedByCustomRule": false,
      "issue": "The IAM Policy grants all permissions to all resources",
      "impact": "Any identity with this policy will have full administrative rights in the account",
      "resolve": "Set `Actions` and `Resources` attributes to limited subset, e.g `Actions: ['s3:Create*']`",
      "remediation": {
        "cloudformation": "Set `Actions` and `Resources` attributes to limited subset, e.g `Actions: ['s3:Create*']`",
        "terraform": "Set `Actions` and `Resources` attributes to limited subset, e.g `Actions: ['s3:Create*']`"
      },
      "lineNumber": 20,
      "iacDescription": {
        "issue": "The IAM Policy grants all permissions to all resources",
        "impact": "Any identity with this policy will have full administrative rights in the account",
        "resolve": "Set `Actions` and `Resources` attributes to limited subset, e.g `Actions: ['s3:Create*']`"
      },
      "publicId": "SNYK-CC-TF-119",
      "msg": "data.aws_iam_policy_document[foo]",
      "references": [
        "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html"
      ],
      "path": ["data", "aws_iam_policy_document[foo]"],
      "compliance": []
    }
  ]
}
    ]]
    local result = parser(output, bufnr)
    local expected = {
      {
        source = "snyk",
        message = "IAM Policy grants full administrative rights - The IAM Policy grants all permissions to all resources - Any identity with this policy will have full administrative rights in the account",
        lnum = 19,
        end_lnum = 19,
        col = 0,
        severity = vim.diagnostic.severity.WARN,
        code = "SNYK-CC-TF-119",
      },
    }
    assert.are.same(expected, result)
  end)
end)
