local messages = {
  file_not_covered = 'No test coverage was found for this file',
  multiple_lines_not_covered = 'No test coverage found for these lines',
  line_not_covered = 'No test coverage found for this line',
  testing_error = 'No test coverage analysis could be performed due to errors'
}

local severities = {
  error = vim.diagnostic.severity.ERROR,
  info = vim.diagnostic.severity.INFO,
}

local ignored_files = {
  "setup.py",
  "docs/conf.py",
  "test_.*.py",
  "__init__.py",
  "conftest.py",
}

local source_pytestcov = "pytest-cov"

return {
  cmd = 'pytest',
  stdin = false,
  args = {"--cov-reset", "--cov-report=term-missing", "--cov=."},
  append_fname = false,
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local buffer_report
    local pattern_data_from_report = "(%d+)%%   (.*)"
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

    for _, ignored_file in ipairs(ignored_files) do
      if string.find(buffer_path, ignored_file) then
          return {}
      end
    end

    for line in string.gmatch(output, "[^\n]+") do
      local file_path_relative = string.match(line, "(.*.py) ");
      if file_path_relative ~= nil then
        if string.find(buffer_path, file_path_relative) then
          buffer_report = line
          break
        end;
      end;
    end;

    if string.find(output, "Interrupted: ") and buffer_report == nil then
      table.insert(diagnostics, {
        source = source_pytestcov,
        lnum = 0,
        col = 0,
        severity = assert(severities.error, 'missing mapping for severity error'),
        message = messages.testing_error,

      })
      return diagnostics
    end

    if buffer_report == nil then
      table.insert(diagnostics, {
        source = source_pytestcov,
        lnum = 0,
        col = 0,
        severity = assert(severities.info, 'missing mapping for severity info'),
        message = messages.file_not_covered,
      })
      return diagnostics
    end

    if string.find(buffer_report, "100%%") then
      return diagnostics
    end

    local percentage_cover, non_covered_blocks = string.match(buffer_report, pattern_data_from_report)

    if tonumber(percentage_cover) == 0 then
      table.insert(diagnostics, {
        source = source_pytestcov,
        lnum = 0,
        col = 0,
        severity = assert(vim.diagnostic.severity.INFO, 'missing mapping for severity info'),
        message = messages.file_not_covered,
      })
    else
      for non_covered_lines in non_covered_blocks:gmatch("([^,]+),?") do
        if string.find(non_covered_lines, "-") then
          local end_block = tonumber(string.match(non_covered_lines,"-(%d+)"))
          table.insert(diagnostics, {
            source = source_pytestcov,
            lnum = tonumber(string.match(non_covered_lines,"(%d+)")) - 1,
            col = 0,
            end_lnum = end_block,
            severity = assert(severities.info, 'missing mapping for severity info'),
            message = messages.multiple_lines_not_covered .. ' (until line ' .. end_block ..')',
          })
        else
          table.insert(diagnostics, {
            source = source_pytestcov,
            lnum = tonumber(string.match(non_covered_lines,"(%d+).*")) - 1,
            col = 0,
            end_lnum = tonumber(string.match(non_covered_lines,"(%d+).*")),
            severity = assert(vim.diagnostic.severity.INFO, 'missing mapping for severity info'),
            message = messages.line_not_covered
          })
        end
      end
    end
    return diagnostics
  end,
}
