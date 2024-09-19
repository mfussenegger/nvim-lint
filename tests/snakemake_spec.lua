describe("linter.snakemake", function()
  it("can parse linter output", function()
    local parser = require("lint.linters.snakemake").parser
    local bufnr = vim.uri_to_bufnr("file://Snakefile")
    local output = [[
Lints for snakefile Snakefile:
    * Absolute path "/absolute/path/to/file" in line 17:
      Do not define absolute paths inside of the workflow, since this renders your workflow
      irreproducible on other machines. Use path relative to the working directory instead, or
      make the path configurable via a config file.
      Also see:
      https://snakemake.readthedocs.io/en/latest/snakefiles/configuration.html#configuration
    * Mixed rules and functions in same snakefile.:
      Small one-liner functions used only once should be defined as lambda expressions. Other
      functions should be collected in a common module, e.g. 'rules/common.smk'. This makes
      the workflow steps more readable.
      Also see:
      https://snakemake.readthedocs.io/en/latest/snakefiles/modularization.html#includes

Lints for rule rule1 (line 15, Snakefile):
    * Specify a conda environment or container for each rule.:
      This way, the used software for each specific step is documented, and the workflow can
      be executed on any machine without prerequisites.
      Also see:
      https://snakemake.readthedocs.io/en/latest/snakefiles/deployment.html#integrated-package-management
      https://snakemake.readthedocs.io/en/latest/snakefiles/deployment.html#running-jobs-in-containers
    * Shell command directly uses variable foo from outside of the rule:
      It is recommended to pass all files as input and output, and non-file parameters via the
      params directive. Otherwise, provenance tracking is less accurate.
      Also see:
      https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#non-file-parameters-for-rules

]]
    local result = parser(output, bufnr)

    assert.are.same(4, #result)

    local expected_hint_1 = {
      lnum = 0,
      col = 0,
      message = "Mixed rules and functions in same snakefile.",
      severity = vim.diagnostic.severity.HINT,
      source = "snakemake",
    }

    assert.are.same(expected_hint_1, result[1])

    local expected_hint_2 = {
      lnum = 16,
      col = 0,
      message = 'Absolute path "/absolute/path/to/file"',
      severity = vim.diagnostic.severity.HINT,
      source = "snakemake",
    }

    assert.are.same(expected_hint_2, result[2])

    local expected_hint_3 = {
      lnum = 14,
      col = 0,
      message = "Specify a conda environment or container for each rule.",
      severity = vim.diagnostic.severity.HINT,
      source = "snakemake",
    }

    assert.are.same(expected_hint_3, result[3])

    local expected_hint_4 = {
      lnum = 14,
      col = 0,
      message = "Shell command directly uses variable foo from outside of the rule",
      severity = vim.diagnostic.severity.HINT,
      source = "snakemake",
    }

    assert.are.same(expected_hint_4, result[4])
  end)

  it("can parse error output", function()
    local parser = require("lint.linters.snakemake").parser
    local bufnr = vim.uri_to_bufnr("file:///Snakefile")
    local output = [[
KeyError in file Snakefile, line 5:
'nonexistent_key'
  File "Snakefile", line 5, in <module>
]]
    local result = parser(output, bufnr)

    assert.are.same(1, #result)

    local expected_error = {
      lnum = 4,
      col = 0,
      message = "KeyError: 'nonexistent_key'",
      severity = vim.diagnostic.severity.ERROR,
      source = "snakemake",
    }

    assert.are.same(expected_error, result[1])
  end)
end)
