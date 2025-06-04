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
    return {}
  end

  local temp_file = vim.fn.tempname()
  local current_buffer = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(current_buffer)

  if filepath == "" then
    vim.notify("Current buffer has no file associated", vim.log.levels.WARN)
    return {}
  end

  local solution_directory = vim.fn.fnamemodify(solution_file, ":h")

  local relative_filepath = filepath:sub(#solution_directory + 2)
  local cache_directory = vim.fn.stdpath("cache")

  local parser = function(_, bufnr)
    local json = vim.fn.json_decode(vim.fn.readfile(temp_file))
    os.remove(temp_file)
    if not json or not json.runs or not json.runs[1] then
      vim.notify("Invalid SARIF format", vim.log.levels.ERROR)
      return {}
    end
    local results = {}
    local run = json.runs[1]
    local base_uri = run.originalUriBaseIds
        and run.originalUriBaseIds.solutionDir
        and run.originalUriBaseIds.solutionDir.uri
      or ""
    for _, result in ipairs(run.results or {}) do
      local loc = result.locations and result.locations[1] and result.locations[1].physicalLocation
      if loc then
        local relative_path = loc.artifactLocation.uri
        local full_path = vim.uri_to_fname(base_uri .. relative_path)
        local region = loc.region or {}
        local start_line = (region.startLine or 1) - 1
        local start_col = (region.startColumn or 1) - 1
        table.insert(results, {
          bufnr = bufnr,
          lnum = start_line,
          col = start_col,
          end_lnum = (region.endLine or region.startLine or 1) - 1,
          end_col = (region.endColumn or region.startColumn or 1) - 1,
          severity = ({
            error = vim.diagnostic.severity.ERROR,
            warning = vim.diagnostic.severity.WARN,
            note = vim.diagnostic.severity.INFO,
            info = vim.diagnostic.severity.INFO,
          })[result.level] or vim.diagnostic.severity.HINT,
          message = result.message and result.message.text or "No message",
          source = "resharper",
          code = result.ruleId,
          filename = full_path,
        })
      end
    end
    return results
  end

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
      "--output=" .. temp_file,
      "--include=" .. relative_filepath,
      "--caches-home=" .. cache_directory,
      solution_file,
    },
    stream = nil,
    ignore_exitcode = true,
    parser = parser,
  }
end
