-- NOTE: see require("lint.linters.api_linter_buf") for a real-world implementation of api-linter, leveraging the buf CLI.
--
-- api-linter v2.x requires files to be specified as relative paths from the
-- working directory. When using with buf, set cwd to the buf.yaml directory
-- and pass the proto file as a relative path.

--- Get relative path of file from cwd
local function get_relative_path(file, cwd)
  if not cwd:sub(-1) == "/" then
    cwd = cwd .. "/"
  end
  local start, stop = file:find(cwd, 1, true)
  if start == 1 then
    local relative_path = file:sub(stop + 1)
    if relative_path:sub(1, 1) == "/" then
      relative_path = relative_path:sub(2)
    end
    return relative_path
  else
    return file
  end
end

return {
  cmd = "api-linter",
  stdin = false,
  -- NOTE: append_fname is false because api-linter v2.x requires relative paths.
  -- The filename is added via the args function below.
  append_fname = false,
  args = {
    "--output-format=json",
    "--disable-rule=core::0191::java-multiple-files",
    "--disable-rule=core::0191::java-package",
    "--disable-rule=core::0191::java-outer-classname",
    function()
      -- Manually add the filename as relative path from cwd.
      -- This is required for api-linter v2.x which expects relative paths.
      local bufpath = vim.fn.expand("%:p")
      local cwd = vim.fn.getcwd()
      return get_relative_path(bufpath, cwd)
    end,
  },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    if output == "" then
      return {}
    end
    local ok, json_output = pcall(vim.json.decode, output)
    if not ok then
      return {}
    end
    local diagnostics = {}
    if json_output == nil then
      return diagnostics
    end
    for _, item in ipairs(json_output) do
      for _, problem in ipairs(item.problems or {}) do
        table.insert(diagnostics, {
          -- Don't set file field - let nvim-lint use current buffer
          message = problem.message,
          code = problem.rule_id .. " " .. problem.rule_doc_uri,
          severity = vim.diagnostic.severity.WARN,
          lnum = problem.location.start_position.line_number - 1,
          col = problem.location.start_position.column_number - 1,
          end_lnum = problem.location.end_position.line_number - 1,
          end_col = problem.location.end_position.column_number - 1,
        })
      end
    end
    return diagnostics
  end,
}
