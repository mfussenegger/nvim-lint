-- Sample biome lint --reporter=github output:
--
-- ::notice title=lint/suspicious/noExplicitAny,file=./src/app.tsx,line=9,endLine=9,col=64,endColumn=67::Unexpected any. Specify a different type.
-- ::warning title=lint/suspicious/noEvolvingTypes,file=./src/app.tsx,line=10,endLine=10,col=7,endColumn=13::The type of this variable may evolve implicitly to any type, including the any type.
-- ::error title=lint/suspicious/noImplicitAnyLet,file=./src/app.tsx,line=10,endLine=10,col=7,endColumn=13::This variable implicitly has the any type.

-- Sample biome parse error
-- ./biome.json:43:3 parse ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
--   ✖ expected `,` but instead found `"css"`
--
--     41 │     "linter": { "enabled": true }
--     42 │   }
--   > 43 │   "css": {
--        │   ^^^^^
--     44 │     "formatter": { "enabled": true },
--     45 │     "linter": { "enabled": true }
--
--   ℹ Remove "css"
--
--
-- configuration ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
--   ✖ Biome exited because the configuration resulted in errors. Please fix them.

local binary_name = "biome"

local reporterGithubParser = require("lint.parser").from_pattern(
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
)

-- when biomejs can't parse the file, the parse error does not look like the
-- --reporter=github format, it is still important diagnostics, especially for json
local parseErrorParser = function(output)
  local diagnostics = {}

  -- The diagnostic details we need are spread in the first 3 lines of
  -- each error report.  These variables are declared out of the FOR
  -- loop because we need to carry their values to parse multiple lines.
  local fetch_message = false
  local lnum, col, code, message

  -- When a lnum:col:code line is detected fetch_message is set to true.
  -- While fetch_message is true we will search for the error message.
  -- When a error message is detected, we will create the diagnostic and
  -- set fetch_message to false to restart the process and get the next
  -- diagnostic.
  for _, line in ipairs(vim.fn.split(output, "\n")) do
    if fetch_message then
      _, _, message = string.find(line, "%s×(.+)")

      if message then
        message = (message):gsub("^%s+×%s*", "")

        table.insert(diagnostics, {
          source = "biomejs",
          lnum = tonumber(lnum) - 1,
          col = tonumber(col),
          message = message,
          code = code,
        })

        fetch_message = false
      end
    else
      _, _, lnum, col, code = string.find(line, "[^:]+:(%d+):(%d+)%s([%a%/]+)")

      if lnum then
        fetch_message = true
      end
    end
  end

  return diagnostics
end

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

  parser = function(output, bufnr, linter_cwd)
    local result = reporterGithubParser(output, bufnr, linter_cwd)
    if #result ~= 0 then
      return result
    end

    result = parseErrorParser(output)
    return result
  end,
}
