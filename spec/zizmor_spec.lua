describe('linter.zizmor', function()
  it('can parse the output', function()
    local parser = require('lint.linters.zizmor').parser
    local result = parser([[
[
  {
    "ident": "excessive-permissions",
    "desc": "overly broad permissions",
    "url": "https://docs.zizmor.sh/audits/#excessive-permissions",
    "determinations": {
      "confidence": "Medium",
      "severity": "Medium",
      "persona": "Regular"
    },
    "locations": [
      {
        "symbolic": {
          "key": {
            "Local": {
              "prefix": null,
              "given_path": "./.github/workflows/lintcommit_dummy.yml"
            }
          },
          "annotation": "this job",
          "route": {
            "route": [
              {
                "Key": "jobs"
              },
              {
                "Key": "lint-commits"
              }
            ]
          },
          "feature_kind": "Normal",
          "kind": "Related"
        },
        "concrete": {
          "location": {
            "start_point": {
              "row": 11,
              "column": 2
            },
            "end_point": {
              "row": 16,
              "column": 0
            },
            "offset_span": {
              "start": 434,
              "end": 563
            }
          },
          "feature": "  lint-commits:\n    runs-on: ubuntu-latest\n    if: github.event.pull_request.draft == false\n    steps:\n      - run: echo \"success\"\n",
          "comments": []
        }
      },
      {
        "symbolic": {
          "key": {
            "Local": {
              "prefix": null,
              "given_path": "./.github/workflows/lintcommit_dummy.yml"
            }
          },
          "annotation": "default permissions used due to no permissions: block",
          "route": {
            "route": [
              {
                "Key": "jobs"
              },
              {
                "Key": "lint-commits"
              }
            ]
          },
          "feature_kind": "Normal",
          "kind": "Primary"
        },
        "concrete": {
          "location": {
            "start_point": {
              "row": 11,
              "column": 2
            },
            "end_point": {
              "row": 16,
              "column": 0
            },
            "offset_span": {
              "start": 434,
              "end": 563
            }
          },
          "feature": "  lint-commits:\n    runs-on: ubuntu-latest\n    if: github.event.pull_request.draft == false\n    steps:\n      - run: echo \"success\"\n",
          "comments": []
        }
      }
    ],
    "ignored": false
  }
]
]], vim.api.nvim_get_current_buf())
    assert.are.same(1, #result)

    local expected = {
      source = "zizmor",
      code = "excessive-permissions",
      message = "overly broad permissions",
      col = 2,
      lnum = 11,
      end_col = 0,
      end_lnum = 16,
      severity = vim.diagnostic.severity.WARN,
      user_data = {
        lsp = {
          codeDescription = {
            href = "https://docs.zizmor.sh/audits/#excessive-permissions",
          },
          relatedInformation = {
            {
              message = "default permissions used due to no permissions: block",
              location = {
                uri = "file://./.github/workflows/lintcommit_dummy.yml",
                range = {
                  ["start"] = {
                    line = 11,
                    character = 2,
                  },
                  ["end"] = {
                    line = 16,
                    character = 0,
                  },
                },
              },
            },
            {
              message = "this job",
              location = {
                uri = "file://./.github/workflows/lintcommit_dummy.yml",
                range = {
                  ["start"] = {
                    line = 11,
                    character = 2,
                  },
                  ["end"] = {
                    line = 16,
                    character = 0,
                  },
                },
              },

            },
          },
        },
      },
    }
    assert.are.same(expected, result[1])
  end)
end)
