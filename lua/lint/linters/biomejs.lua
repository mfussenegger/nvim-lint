-- Sample biome lint --reporter=github output:
--
-- ::notice title=lint/suspicious/noExplicitAny,file=./src/app.tsx,line=9,endLine=9,col=64,endColumn=67::Unexpected any. Specify a different type.
-- ::warning title=lint/suspicious/noEvolvingTypes,file=./src/app.tsx,line=10,endLine=10,col=7,endColumn=13::The type of this variable may evolve implicitly to any type, including the any type.
-- ::error title=lint/suspicious/noImplicitAnyLet,file=./src/app.tsx,line=10,endLine=10,col=7,endColumn=13::This variable implicitly has the any type.

local binary_name = "biome"

return {
  cmd = function()
    local local_binary

    if vim.version.cmp(vim.version(), { 0, 10, 0 }) == 1 then
      local rootDir = vim.fs.root(0, "node_modules")
      local_binary = rootDir .. "/node_modules/.bin/" .. binary_name
    else
      local_binary =
        vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    end

    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  args = { "lint", "--reporter=github" },
  stdin = false,
  ignore_exitcode = true,
  stream = "both",
  parser = require("lint.parser").from_pattern(
    "::(.+) title=(.+),file=(.+),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+)::(.+)",
    {
      "severity",
      "code",
      "file",
      "lnum",
      "end_lnum",
      "col",
      "end_col",
      "message",
    },
    {
      ["error"] = vim.diagnostic.severity.ERROR,
      ["warning"] = vim.diagnostic.severity.WARN,
      ["notice"] = vim.diagnostic.severity.INFO,
    },
    { ["source"] = "biomejs" },
    { lnum_offset = 0, end_lnum_offset = 0, end_col_offset = -1 }
  ),
}
