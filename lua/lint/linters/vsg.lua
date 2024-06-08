local pattern = "(%w+).*%((%d+)%)(.*)%s+%-%-%s+(.+)"
local groups = { "severity", "lnum", "code", "message" }
local severity_map = {
  ["ERROR"] = vim.diagnostic.severity.ERROR,
  ["WARNING"] = vim.diagnostic.severity.WARN,
  ["INFORMATION"] = vim.diagnostic.severity.INFO,
  ["HINT"] = vim.diagnostic.severity.HINT,
}

local function find_local_config()
  local current_file = vim.api.nvim_buf_get_name(0)
  local filenames = { ".vsg.yaml", ".vsg.yml", ".vsg.json" }
  return vim.fs.find(filenames, {
    path = vim.fs.dirname(current_file),
    upward = true,
  })[1]
end

local function find_global_config()
  local xdg_config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
  local filenames = { "vsg.yaml", "vsg.yml", "vsg.json" }
  return vim.fs.find(filenames, {
    path = xdg_config_home .. "/vsg",
    upward = false,
  })[1]
end

local config_file = find_local_config() or find_global_config()
local args = { "-of", "syntastic", "--stdin" }

if config_file then
  table.insert(args, "-c")
  table.insert(args, config_file)
end

return {
  cmd = "vsg",
  stdin = true,
  args = args,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, {
    source = "vsg",
  }),
}
