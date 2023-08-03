-- See the source for the formats
-- https://github.com/bazelbuild/buildtools/blob/b31f2c13c407575100d4614bcc9a3c60be07cc1c/buildifier/utils/diagnostics.go#L39

local function get_cur_file_type(bufnr)
  -- Logic taken from https://github.com/bazelbuild/buildtools/blob/master/build/lex.go#L125
  bufnr = bufnr or 0
  local fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  fname = string.lower(fname)

  if fname == "module.bazel" then
    return "module"
  elseif vim.endswith(fname, ".bzl") then
    return "bzl"
  elseif vim.endswith(fname, ".sky") then
    return "default"
  elseif fname == "build" or vim.startswith(fname, "build.") or vim.endswith(fname, ".build") then
    return "build"
  elseif fname == "workspace" or vim.startswith(fname, "workspace.") or vim.endswith(fname, ".workspace") then
    return "workspace"
  else
    return "default"
  end
end

local function parse_stdout_json(bufnr, line)
  local diagnostics = {}

  local out = vim.json.decode(line)
  if out.success == true then
    return diagnostics
  end

  local f = out.files[1]
  if not f.warnings then
    return diagnostics
  end

  if not f.formatted then
    table.insert(diagnostics, {
      bufnr = bufnr,
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.HINT,
      source = 'buildifier',
      message = 'Please run buildifier to reformat the file contents.',
      code = 'reformat',
    })
  end

  for _, item in ipairs(f.warnings) do
    local severity = vim.diagnostic.severity.INFO
    if item.actionable == true then
      severity = vim.diagnostic.severity.WARN
    end

    table.insert(diagnostics, {
      bufnr = bufnr,
      lnum = item.start.line - 1,
      col = item.start.column - 1,
      end_lnum = item["end"].line - 1,
      end_col = item["end"].column - 1,
      severity = severity,
      source = 'buildifier',
      message = item.message .. '\n\n' .. item.url,
      code = item.category,
    })
  end

  return diagnostics
end

local function parse_stderr_line(bufnr, line)
  -- This part parses the buildifier output that usually comes via stderr which
  -- is not in JSON format yet.
  local parts = vim.split(line, ":")
  local lnum, col, message = 0, 0, ""

  if #parts >= 4 then
    lnum = tonumber(parts[2]) - 1
    col = tonumber(parts[3]) - 1
    message = table.concat(parts, ":", 4)
  elseif #parts == 3 then
    message = parts[3]
  elseif #parts == 2 then
    message = parts[2]
  elseif #parts == 1 then
    message = line
  end

  if message ~= "" then
    return {{
      bufnr = bufnr,
      lnum = lnum,
      col = col,
      severity = vim.diagnostic.severity.ERROR,
      source = 'buildifier',
      message = message:gsub("^%s+", ""),
      code = 'syntax',
    }}
  end

  return {}
end

return {
  cmd = 'buildifier',
  args = {
    "-lint", "warn",
    "-mode", "check",
    "-warnings", "all",
    "-format", "json",
    "-type", get_cur_file_type
  },
  stdin = true,
  append_fname = false,
  stream = "both",
  parser = function(output, bufnr)
    local diagnostics = {}

    local lines = vim.split(output, '\n')
    for _, line in ipairs(lines) do
      if vim.startswith(line, '{') then
        for _, d in ipairs(parse_stdout_json(bufnr, line)) do
          table.insert(diagnostics, d)
        end
      else
        for _, d in ipairs(parse_stderr_line(bufnr, line)) do
          table.insert(diagnostics, d)
        end
      end
    end
    return diagnostics
  end,
}
