local severities = {
  note = vim.diagnostic.severity.INFO,
  warning = vim.diagnostic.severity.WARN,
  help = vim.diagnostic.severity.HINT,
}

local function parse(diagnostics, file_name, item)
  for _, span in ipairs(item.spans) do
    if span.file_name == file_name then
      local message = item.message
      if span.suggested_replacement ~= vim.NIL then
        message = message .. " (" .. tostring(span.suggested_replacement) .. ")"
      end

      table.insert(diagnostics, {
        lnum = span.line_start - 1,
        end_lnum = span.line_end - 1,
        col = span.column_start - 1,
        end_col = span.column_end - 1,
        severity = severities[item.level],
        source = "clippy",
        message = message
      })
    end
  end

  for _, child in ipairs(item.children) do
    parse(diagnostics, file_name, child)
  end
end

return {
  cmd = "cargo",
  args = { "clippy", "--message-format=json" },
  stdin = false,
  append_fname = false,
  parser = function(output, bufnr)
    local diagnostics = {}
    local items = #output > 0 and vim.split(output, "\n") or {}
    local file_name = vim.fn.expand("%")

    for _, i in ipairs(items) do
      local item = i ~= "" and vim.json.decode(i) or {}
      -- cargo also outputs build artifacts messages in addition to diagnostics
      if item and item.reason == "compiler-message" then
        parse(diagnostics, file_name, item.message)
      end
    end
    return diagnostics
  end,
}
