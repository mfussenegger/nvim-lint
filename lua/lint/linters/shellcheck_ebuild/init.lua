---@type string the exported files dir
local exportedFileDir = vim.fs.joinpath(vim.fn.stdpath("cache"), "nvim-lint", "shellcheck_ebuild")
vim.fn.mkdir(exportedFileDir, "p")

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  style = vim.diagnostic.severity.HINT,
}

---@return string filepath after cache file creation
local function shellcheck_ebuild_custom_file()
  ---@type string the exported file path
  local exportedFilePath = vim.fs.joinpath(exportedFileDir, vim.fn.sha256(vim.fn.expand("%:p")))
  local mainfile = io.open(vim.fn.expand("%:p"), "r")
  ---@type string the data inside the current file
  local fileContent
  if mainfile ~= nil then
    fileContent = mainfile:read("*a")
    mainfile:close()
  end
  local exportedFile = io.open(exportedFilePath, "w")
  if exportedFile ~= nil then
    exportedFile:write(fileContent .. "\n" .. require("lint.linters.shellcheck_ebuild.ebuild-vars"))
    exportedFile:close()
  end
  return exportedFilePath
end

---@type lint.Linter
return {
  name = "shellcheck_ebuild",
  cmd = "shellcheck",
  stdin = false,
  append_fname = false, -- Automatically append the file name to `args` if `stdin = false` (default: true)
  args = {
    "--shell",
    "bash", --ebuild is a subset of bash: https://dev.gentoo.org/~ulm/pms/head/pms.html#ebuild-file-format
    "--enable",
    "quote-safe-variables,require-variable-braces", -- these are often advised
    "--format",
    "json1",
    shellcheck_ebuild_custom_file,
  },
  ignore_exitcode = true,
  parser = function(output)
    if output == "" then
      return {}
    end
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded.comments or {}) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        col = item.column - 1,
        end_lnum = item.endLine - 1,
        end_col = item.endColumn - 1,
        code = item.code,
        source = "shellcheck_ebuild",
        user_data = {
          lsp = {
            code = item.code,
          },
        },
        severity = assert(severities[item.level], "missing mapping for severity " .. item.level),
        message = item.message,
      })
    end
    return diagnostics
  end,
}
