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

  -- Custom function to find file upwards
  local function find_file_upwards(filename, start_dir)
    local current_dir = start_dir
    while current_dir ~= "/" do
      local file_path = current_dir .. "/" .. filename
      if vim.fn.filereadable(file_path) == 1 then
        return file_path
      end
      current_dir = vim.fn.fnamemodify(current_dir, ":h")
    end
    return nil
  end

  local buffer_parent_dir = vim.fn.expand("%:p:h")
  local buf_config_filepath = find_file_upwards("buf.yaml", buffer_parent_dir)
    or find_file_upwards("buf.yml", buffer_parent_dir)

  if not buf_config_filepath then
    error("Buf config file not found")
  end

  -- build the descriptor file.
  local buf_config_folderpath = vim.fn.fnamemodify(buf_config_filepath, ":h")
  local buf_cmd = string.format(
    "cd %s && buf build -o %s",
    vim.fn.shellescape(buf_config_folderpath),
    vim.fn.shellescape(descriptor_filepath)
  )
  local output = vim.fn.system(buf_cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    error("Command failed: " .. buf_cmd .. "\n" .. output)
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
