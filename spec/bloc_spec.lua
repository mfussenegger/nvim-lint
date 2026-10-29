describe("linter.bloc", function()
  it("should ignore empty output", function()
    local parser = require("lint.linters.bloc").parser

    assert.are.same({}, parser("", vim.api.nvim_get_current_buf()))
    assert.are.same({}, parser("  ", vim.api.nvim_get_current_buf()))
  end)

  it("should parse the output", function()
    local parser = require("lint.linters.bloc").parser
    local bufnr = vim.uri_to_bufnr("file:///lib/example.dart")

    local output = [[
warning[avoid_public_bloc_methods]: Avoid public methods on bloc instances.
 --> lib/example.dart:16
  |
  |   void publicMethod() {
  |        ^^^^^^^^^^^^
  = hint: Prefer notifying bloc instances via `add`.
 docs: https://bloclibrary.dev/lint-rules/avoid_public_bloc_methods

error[avoid_public_fields]: Avoid public fields.
 --> lib/example.dart:8
  |
  |   String publicField = "public";
  |   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  = hint: Prefer using the `state` to hold all public fields.
 docs: https://bloclibrary.dev/lint-rules/avoid_public_fields

info[prefer_file_naming_conventions]: Prefer following file naming conventions.
 --> lib/example.dart:7
  |
  | class WrongNameBloc extends Bloc<ExampleEvent, String> {
  |       ^^^^^^^^^^^^^
  = hint: Prefer moving WrongNameBloc into wrong_name_bloc.dart.dart
 docs: https://bloclibrary.dev/lint-rules/prefer_file_naming_conventions

3 issues found
Analyzed 4 files
]]

    local result = parser(output, bufnr)
    assert.are.same(3, #result)

    local expected_error = {
      bufnr = bufnr,
      source = "bloc",
      code = "avoid_public_bloc_methods",
      message = "Avoid public methods on bloc instances.",
      severity = vim.diagnostic.severity.WARN,
      lnum = 15,
      col = 7,
      end_col = 19,
    }

    local expected_warning = {
      bufnr = bufnr,
      source = "bloc",
      code = "avoid_public_fields",
      message = "Avoid public fields.",
      severity = vim.diagnostic.severity.ERROR,
      lnum = 7,
      col = 2,
      end_col = 32,
    }

    local expected_info = {
      bufnr = bufnr,
      source = "bloc",
      code = "prefer_file_naming_conventions",
      message = "Prefer following file naming conventions.",
      severity = vim.diagnostic.severity.INFO,
      lnum = 6,
      col = 6,
      end_col = 19,
    }

    assert.are.same(expected_error, result[1])
    assert.are.same(expected_warning, result[2])
    assert.are.same(expected_info, result[3])
  end)
end)
