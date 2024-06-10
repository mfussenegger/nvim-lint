local pattern = "(%w+).*%((%d+)%)(.*)%s+%-%-%s+(.+)"
local groups = { "severity", "lnum", "code", "message" }
local severity_map = {
  ["ERROR"] = vim.diagnostic.severity.ERROR,
  ["WARNING"] = vim.diagnostic.severity.WARN,
  ["INFORMATION"] = vim.diagnostic.severity.INFO,
  ["HINT"] = vim.diagnostic.severity.HINT,
}

local config_files = {
  "vsg_config.yaml",
  "vsg_config.yml",
  "vsg_config.json",
  "vsg.yaml",
  "vsg.yml",
  "vsg.json",
  ".vsg_config.yaml",
  ".vsg_config.yml",
  ".vsg_config.json",
  ".vsg.yaml",
  ".vsg.yml",
  ".vsg.json",
}

local function find_config(dirname)
  local paths = {
    dirname,
    (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/vsg",
  }

  for _, path in ipairs(paths) do
    local config = vim.fs.find(config_files, {
      path = path,
      upward = path == dirname,
    })[1]
    if config then
      return config
    end
  end
end

local function get_args(dirname)
  local args = { "-of", "syntastic", "--stdin" }
  local config_file = find_config(dirname)

  if config_file then
    table.insert(args, "-c")
    table.insert(args, config_file)
  end

  return args
end

return {
  cmd = "vsg",
  stdin = true,
  args = get_args(vim.fn.expand("%:p:h")),
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, {
    source = "vsg",
  }),
}
