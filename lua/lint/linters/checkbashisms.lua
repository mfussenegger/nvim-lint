return {
  cmd = "checkbashisms",
  stdin = false, -- Does not take stdin unless we give "-" as an arg
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true, -- exits > 0 if emits lints
  args = {
    "--lint",
  },
  -- checkbashism's manpage gives the following as the lint style output:
  -- {filename}:{lineno}:1: warning: possible bashism; {explanation}
  -- i.e. the column number and severity is entirely static
  parser = require("lint.parser").from_errorformat("%f:%l:1: warning: possible bashism; %m", {
    source = "checkbashisms",
    severity = vim.diagnostic.severity.WARN,
  }),
}
