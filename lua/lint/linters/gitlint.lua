local gitlint_numbered_parser = require("lint.parser").from_pattern("^(%d+): (%w+) (.*)$", { "lnum", "code", "message" })
local gitlint_generic_parser = require("lint.parser").from_pattern("^-: (%w+) (.*)$", { "code", "message" })
local function gitlint_parsers(output, bufnr, linter_cwd)
  local result = gitlint_numbered_parser(output, bufnr, linter_cwd)
  vim.list_extend(result, gitlint_generic_parser(output, bufnr, linter_cwd))
  return result
end

return {
  cmd = "gitlint",
  stdin = true,
  args = {
    "--staged",
    "--msg-filename",
    function() return vim.api.nvim_buf_get_name(0) end
  },
  stream = "stderr",
  ignore_exitcode = true,
  parser = gitlint_parsers,
}
