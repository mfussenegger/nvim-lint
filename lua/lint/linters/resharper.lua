local function find_solution_upward()
  local dir = vim.fn.getcwd()
  while dir and dir ~= "/" do
    local files = vim.fn.globpath(dir, "*.sln", false, true)
    if not vim.tbl_isempty(files) then
      return files[1]
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

return function()
  local solution_file = find_solution_upward()
  if not solution_file then
    vim.notify("No solution file found in parent directories", vim.log.levels.WARN)
    -- TODO: Fallback to csproj file if missing solution
    return {}
  end

  local current_buffer = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(current_buffer)

  if filepath == "" then
    vim.notify("Current buffer has no file associated", vim.log.levels.WARN)
    return {}
  end

  local solution_directory = vim.fn.fnamemodify(solution_file, ":h")

  local relative_filepath = filepath:sub(#solution_directory + 2)
  local cache_directory = vim.fn.stdpath("cache")

  return {
    cmd = "jb",
    stdin = false,
    append_fname = false,
    args = {
      "inspectcode",
      "--no-swea",
      "--no-build",
      "--jobs=0",
      "--severity=INFO",
      "--output=-",
      "--include=" .. relative_filepath,
      "--caches-home=" .. cache_directory,
      solution_file,
    },
    stream = nil,
    -- ignore_exitcode = true,
    parser = require("lint.parser").for_sarif(),
  }
end
