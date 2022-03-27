local vim = vim
local describe = describe
local it = it

local test_output =
  [[
[
  {
    "commentDirectiveParser": {
      "lastLine": 59,
      "ruleStore": {
        "disableRuleByLine": [
          null,
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {},
          {}
        ],
        "disableAllByLine": [
          null,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false
        ],
        "lastLine": 59
      }
    },
    "reports": [
      {
        "line": 4,
        "column": 1,
        "severity": 2,
        "message": "Compiler version ^0.8.0 does not satisfy the ^0.8.1 semver requirement",
        "ruleId": "compiler-version",
        "fix": null
      },
      {
        "line": 38,
        "column": 3,
        "severity": 3,
        "message": "Explicitly mark visibility in function",
        "ruleId": "func-visibility",
        "fix": null
      },
      {
        "line": 38,
        "column": 19,
        "severity": 3,
        "message": "Code contains empty blocks",
        "ruleId": "no-empty-blocks",
        "fix": null
      }
    ],
    "config": {
      "max-states-count": [
        "warn",
        15
      ],
      "no-empty-blocks": "warn",
      "no-unused-vars": "warn",
      "payable-fallback": "warn",
      "reason-string": [
        "warn",
        {
          "maxLength": 32
        }
      ],
      "quotes": [
        "error",
        "double"
      ],
      "const-name-snakecase": "warn",
      "contract-name-camelcase": "warn",
      "event-name-camelcase": "warn",
      "func-name-mixedcase": "warn",
      "use-forbidden-name": "warn",
      "var-name-mixedcase": "warn",
      "imports-on-top": "warn",
      "visibility-modifier-order": "warn",
      "avoid-call-value": "warn",
      "avoid-low-level-calls": "warn",
      "avoid-sha3": "warn",
      "avoid-suicide": "error",
      "avoid-throw": "warn",
      "avoid-tx-origin": "warn",
      "check-send-result": "warn",
      "compiler-version": [
        "error",
        "^0.8.1"
      ],
      "func-visibility": [
        "warn",
        {
          "ignoreConstructors": true
        }
      ],
      "multiple-sends": "warn",
      "no-complex-fallback": "warn",
      "no-inline-assembly": "warn",
      "not-rely-on-block-hash": "warn",
      "not-rely-on-time": "warn",
      "reentrancy": "warn",
      "state-visibility": "warn"
    },
    "file": "Test.sol"
  }
]

]]

describe(
  "linter.solhint",
  function()
    it(
      "can parse solhint output",
      function()
        local parser = require("lint.linters.solhint").parser
        local bufnr = vim.uri_to_bufnr("file:///Test.sol")
        local result = parser(test_output, bufnr)

        local expected_1 = {
          source = "solhint",
          message = "Compiler version ^0.8.0 does not satisfy the ^0.8.1 semver requirement",
          lnum = 3,
          col = 0,
          end_lnum = 3,
          end_col = 0,
          severity = vim.diagnostic.severity.ERROR,
          user_data = {
            lsp = {
              code = "compiler-version"
            }
          }
        }
        assert.are.same(expected_1, result[1])

        local expected_2 = {
          source = "solhint",
          message = "Explicitly mark visibility in function",
          lnum = 37,
          col = 2,
          end_lnum = 37,
          end_col = 2,
          severity = vim.diagnostic.severity.WARN,
          user_data = {
            lsp = {
              code = "func-visibility"
            }
          }
        }
        assert.are.same(expected_2, result[2])

        local expected_3 = {
          source = "solhint",
          message = "Code contains empty blocks",
          lnum = 37,
          col = 18,
          end_lnum = 37,
          end_col = 18,
          severity = vim.diagnostic.severity.WARN,
          user_data = {
            lsp = {
              code = "no-empty-blocks"
            }
          }
        }
        assert.are.same(expected_3, result[3])
      end
    )
  end
)
