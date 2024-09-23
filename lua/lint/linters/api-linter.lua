local descriptor_filepath = os.tmpname()
local cleanup_descriptor = function()
  os.remove(descriptor_filepath)
end

--- Function to set the `--descriptor-set-in` argument.
--- This requires the buf CLI, which will first build the descriptor file.
local function descriptor_set_in()
  if vim.fn.executable("buf") == 0 then
    error("buf CLI not found")
  end

  -- search for the buf config, searching upwards from the current buffer's directory until $HOME.
  local buffer_parent_dir = vim.fn.expand("%:p:h") -- the path to the folder of the opened .proto file.
  local buf_config_filepaths = vim.fs.find(
    { "buf.yaml", "buf.yml" },
    { path = buffer_parent_dir, upward = true, stop = vim.fs.normalize("~"), type = "file", limit = 1 }
  )
  if #buf_config_filepaths == 0 then
    error("Buf config file not found")
  end
  local buf_config_filepath = buf_config_filepaths[1]

  -- build the descriptor file.
  local buf_config_folderpath = vim.fn.fnamemodify(buf_config_filepath, ":h")
  local buf_cmd = { "buf", "build", "-o", descriptor_filepath }
  local buf_cmd_opts = { cwd = buf_config_folderpath }
  local obj = vim.system(buf_cmd, buf_cmd_opts):wait()
  if obj.code ~= 0 then
    error("Command failed: " .. vim.inspect(buf_cmd) .. "\n" .. obj.stderr)
  end

  -- return the argument to be passed to the linter.
  return "--descriptor-set-in=" .. descriptor_filepath
end

return {
  cmd = "api-linter",
  stdin = false,
  append_fname = true,
  args = {
    "--output-format=json",
    "--disable-rule=core::0191::java-multiple-files",
    "--disable-rule=core::0191::java-package",
    "--disable-rule=core::0191::java-outer-classname",
    descriptor_set_in,
  },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    if output == "" then
      return {}
    end
    local json_output = vim.json.decode(output)
    local diagnostics = {}
    if json_output == nil then
      return diagnostics
    end
    for _, item in ipairs(json_output) do
      for _, problem in ipairs(item.problems) do
        table.insert(diagnostics, {
          message = problem.message,
          file = item.file,
          code = problem.rule_id .. " " .. problem.rule_doc_uri,
          severity = vim.diagnostic.severity.WARN,
          lnum = problem.location.start_position.line_number - 1,
          col = problem.location.start_position.column_number - 1,
          end_lnum = problem.location.end_position.line_number - 1,
          end_col = problem.location.end_position.column_number - 1,
        })
      end
    end
    cleanup_descriptor()
    return diagnostics
  end,
}
