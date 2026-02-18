local function get_config()
  local local_cfg = vim.fn.findfile(".bake.toml", ".;")
  return local_cfg ~= "" and local_cfg or vim.fn.expand("~/.config/.bake.toml")
end

return {
  cmd = "mbake",
  stdin = false,
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true,
  args = {
    "validate",
    "--config",
    get_config(),
  },
  parser = function(output, bufnr)
    local diagnostics = {}

    for _, line in ipairs(vim.split(output, "\n")) do
      local file, lnum, message = line:match("%s*([^:]+):(%d+):%s*(.+)")

      if file and lnum and message then
        message = message:gsub("^%*+%s*", ""):gsub("%s*Stop%.$", "")

        table.insert(diagnostics, {
          lnum = tonumber(lnum) - 1,
          col = 0,
          severity = vim.diagnostic.severity.ERROR,
          source = "mbake",
          message = vim.trim(message),
        })
      end
    end

    return diagnostics
  end,
}
