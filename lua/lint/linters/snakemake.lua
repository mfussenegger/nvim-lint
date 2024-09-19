return {
  name = "snakemake",
  cmd = "snakemake",
  stdin = false,
  append_fname = true,
  args = { "--lint", "text", "--snakefile" },
  stream = "stderr",
  ignore_exitcode = true,
  env = nil,
  parser = function(lint_output, buffnr)
    local diagnostics = {}
    local current_diagnostic = nil

    if string.find(lint_output, "Lints for") then
      for lint_type, lines in lint_output:gmatch("Lints for (%a+) (.-)\n\n\n?") do
        if lint_type == "rule" then
          local linenum = lines:match("line (%d+),")
          lines = string.gsub(lines, "\n", "")
          -- rule-specific lints
          -- display all at start of rule
          for errmessage in lines:gmatch("%*% (.-):") do
            if errmessage then
              current_diagnostic = {
                lnum = tonumber(linenum) - 1,
                col = 0,
                message = errmessage,
                source = "snakemake",
                severity = vim.diagnostic.severity.HINT,
              }
              table.insert(diagnostics, current_diagnostic)
              current_diagnostic = nil
            end
          end
        elseif lint_type == "snakefile" then
          -- general Snakefile lints related to the whole file
          -- display all at start of file
          for errmessage in lines:gmatch("%* ([^%d]-):") do
            current_diagnostic = {
              lnum = 0,
              col = 0,
              message = errmessage,
              source = "snakemake",
              severity = vim.diagnostic.severity.HINT,
            }
            table.insert(diagnostics, current_diagnostic)
            current_diagnostic = nil
          end
          -- general Snakefile lints related to specific lines
          -- display each at its line
          for errmessage, linenum in lines:gmatch("%* ([^\n]-) in line (%d+):") do
            current_diagnostic = {
              lnum = tonumber(linenum) - 1,
              col = 0,
              message = errmessage,
              source = "snakemake",
              severity = vim.diagnostic.severity.HINT,
            }
            table.insert(diagnostics, current_diagnostic)
            current_diagnostic = nil
          end
        end
      end
    elseif not string.find(lint_output, "Congratulations") then
      -- error encountered while linting
      -- display error type and message at reported line
      local error = nil
      local linenum = 0
      local errmessage = nil
      error, linenum, errmessage = string.match(lint_output, "(.*) in file .*, line (%d+):\n(.*)\n .*")
      if error and errmessage then
        errmessage = error .. ": " .. errmessage
        current_diagnostic = {
          lnum = tonumber(linenum) - 1,
          col = 0,
          message = errmessage,
          source = "snakemake",
          severity = vim.diagnostic.severity.ERROR,
        }
        table.insert(diagnostics, current_diagnostic)
      end
    end

    return diagnostics
  end,
}
