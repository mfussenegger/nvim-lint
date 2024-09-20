return {
  cmd = "ksh",
  stdin = true,
  append_fname = false,
  args = { "-o", "noexec", "-s" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat(
    "ksh:\\ syntax\\ %t%.%#\\ at\\ line\\ %l:\\ %m,ksh:\\ %t%.%#\\ line\\ %l:\\ %m",
    { source = "ksh" }
  ),
}
