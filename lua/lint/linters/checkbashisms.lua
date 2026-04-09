return {
  cmd = "checkbashisms",
  stdin = true, -- Only works if we give "-" as an arg
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true, -- exits > 0 if emits lints
  args = {
    "--lint",
    "-",
  },
  -- checkbashism's manpage gives the following as the lint style output:
  -- {filename}:{lineno}:1: warning: possible bashism; {explanation}
  -- i.e. the column number and severity is entirely static
  -- with stdin the file name is static as well
  parser = require("lint.parser").from_errorformat("(stdin):%l:1: warning: possible bashism; %m", {
    source = "checkbashisms",
    severity = vim.diagnostic.severity.WARN,
  }),
}
