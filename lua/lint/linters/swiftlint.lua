local pattern = "[^:]+:(%d+):(%d+): (%w+): (.+)"
local groups = { "lnum", "col", "severity", "message" }
local defaults = { ["source"] = "swiftlint" }
local severity_map = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}

local cached_config = nil

local function find_config(filename)
  if vim.fs and vim.fs.find then
    return vim.fs.find(filename, {
      upward = true,
      stop = vim.fs.dirname(vim.loop.os_homedir()),
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
  end
  return nil
end

return function()
  local args
  local stdin = false
  cached_config = cached_config or find_config(".swiftlint.yml")

  if cached_config then
    args = {
      "lint",
      "--force-exclude",
      "--use-alternative-excluding",
      "--config",
      cached_config,
    }
  else
    args = {
      "lint",
      "--use-stdin",
    }
    stdin = true
  end

  return {
    cmd = "swiftlint",
    stdin = stdin,
    args = args,
    stream = "stdout",
    ignore_exitcode = true,
    parser = require("lint.parser").from_pattern(pattern, groups, severity_map, defaults),
  }
end
