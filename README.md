# nvim-lint

An asynchronous linter plugin for Neovim (>= 0.6.0) complementary to the
built-in Language Server Protocol support.

## Motivation & Goals

With [ale][1] we already got an asynchronous linter, why write yet another one?

Because [ale][1] reports diagnostics with its own home grown solution and even
includes its own language server client.

`nvim-lint` instead uses the `vim.diagnostic` module to present diagnostics in
the same way the language client built into neovim does.
`nvim-lint` is meant to fill the gaps for languages where either no language
server exists, or where standalone linters provide better results than the
available language server do.

## Installation

- Requires Neovim >= 0.6.0
- `nvim-lint` is a plugin. Install it like any other Neovim plugin.
  - If using [vim-plug][3]: `Plug 'mfussenegger/nvim-lint'`
  - If using [packer.nvim][4]: `use 'mfussenegger/nvim-lint'`


## Usage

Configure the linters you want to run per file type. For example:

```lua
require('lint').linters_by_ft = {
  markdown = {'vale',}
}
```

Then setup a autocmd to trigger linting. For example:

```vimL
au BufWritePost lua require('lint').try_lint()
```

or with Lua autocmds (requires 0.7):

```lua
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
```

Some linters require a file to be saved to disk, others support linting `stdin`
input. For such linters you could also define a more aggressive autocmd, for
example on the `InsertLeave` or `TextChanged` events.


If you want to customize how the diagnostics are displayed, read `:help
vim.diagnostic.config`.


## Available Linters

There is a generic linter called `compiler` that uses the `makeprg` and
`errorformat` options of the current buffer.

Other dedicated linters that are built-in are:

| Tool                               | Linter name       |
| ---------------------------------- | ----------------- |
| Set via `makeprg`                  | `compiler`        |
| [ansible-lint][ansible-lint]       | `ansible_lint`    |
| [cfn-lint][cfn-lint]               | `cfn_lint`        |
| [cfn_nag][cfn_nag]                 | `cfn_nag`         |
| [checkstyle][checkstyle]           | `checkstyle`      |
| [chktex][20]                       | `chktex`          |
| [clang-tidy][23]                   | `clangtidy`       |
| [clazy][30]                        | `clazy`           |
| [clj-kondo][24]                    | `clj-kondo`       |
| [cmakelint][cmakelint]             | `cmakelint`       |
| [codespell][18]                    | `codespell`       |
| [cppcheck][22]                     | `cppcheck`        |
| [cpplint][cpplint]                 | `cpplint`         |
| [credo][credo]                     | `credo`           |
| [cspell][36]                       | `cspell`          |
| [ESLint][25]                       | `eslint`          |
| [eslint_d][37]                     | `eslint_d`        |
| [fennel][fennel]                   | `fennel`          |
| [Flake8][13]                       | `flake8`          |
| [flawfinder][35]                   | `flawfinder`      |
| [Golangci-lint][16]                | `golangcilint`    |
| [glslc][glslc]                     | `glslc`           |
| [DirectX Shader Compiler][dxc]     | `dxc`             |
| [hadolint][28]                     | `hadolint`        |
| [hlint][32]                        | `hlint`           |
| [HTML Tidy][12]                    | `tidy`            |
| [Inko][17]                         | `inko`            |
| [janet][janet]                     | `janet`           |
| [jshint][jshint]                   | `jshint`          |
| [jsonlint][jsonlint]               | `jsonlint`        |
| [ktlint][ktlint]                   | `ktlint`          |
| [lacheck][lacheck]                 | `lacheck`         |
| [Languagetool][5]                  | `languagetool`    |
| [luacheck][19]                     | `luacheck`        |
| [markdownlint][26]                 | `markdownlint`    |
| [mlint][34]                        | `mlint`           |
| [Mypy][11]                         | `mypy`            |
| [Nix][nix]                         | `nix`             |
| [npm-groovy-lint][npm-groovy-lint] | `npm-groovy-lint` |
| [oelint-adv][oelint-adv]           | `oelint-adv`      |
| [phpcs][phpcs]                     | `phpcs`           |
| [proselint][proselint]             | `proselint`       |
| [psalm][psalm]                     | `psalm`           |
| [pycodestyle][pcs-docs]            | `pycodestyle`     |
| [pydocstyle][pydocstyle]           | `pydocstyle`      |
| [Pylint][15]                       | `pylint`          |
| [Revive][14]                       | `revive`          |
| [rflint][rflint]                   | `rflint`          |
| [robocop][robocop]                 | `robocop`         |
| [rstcheck][rstcheck]               | `rstcheck`        |
| [rstlint][rstlint]                 | `rstlint`         |
| [Ruby][ruby]                       | `ruby`            |
| [RuboCop][rubocop]                 | `rubocop`         |
| [Ruff][ruff]                       | `ruff`            |
| [Selene][31]                       | `selene`          |
| [ShellCheck][10]                   | `shellcheck`      |
| [StandardRB][27]                   | `standardrb`      |
| [statix check][33]                 | `statix`          |
| [stylelint][29]                    | `stylelint`       |
| [Nagelfar][nagelfar]               | `nagelfar`        |
| [Vale][8]                          | `vale`            |
| [vint][21]                         | `vint`            |
| [vulture][vulture]                 | `vulture`         |
| [yamllint][yamllint]               | `yamllint`        |

## Custom Linters

You can register custom linters by adding them to the `linters` table, but
please consider contributing a linter if it is missing.


```lua
require('lint').linters.your_linter_name = {
  cmd = 'linter_cmd',
  stdin = true, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
  append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
  args = {}, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
  stream = nil, -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
  ignore_exitcode = false, -- set this to true if the linter exits with a code != 0 and that's considered normal.
  env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
  parser = your_parse_function
}
```

Instead of declaring the linter as a table, you can also declare it as a
function which returns the linter table in case you want to dynamically
generate some of the properties.

`your_parse_function` can be a function which takes two arguments:

- `output`
- `bufnr`


The `output` is the output generated by the linter command.
The function must return a list of diagnostics as specified in `:help
diagnostic-structure`.

You can override the environment that the linting process runs in by setting
the `env` key, e.g.

```lua
env = { ["FOO"] = "bar" }
```

Note that this completely overrides the environment, it does not add new
environment variables. The one exception is that the `PATH` variable will be
preserved if it is not explicitly set.

You can generate a parse function from a Lua pattern or from an `errorformat`
using the function in the `lint.parser` module:

### from_errorformat

```lua
parser = require('lint.parser').from_errorformat(errorformat)
```

The function takes a single argument which is the `errorformat`.


### from_pattern

```lua
parser = require('lint.parser').from_pattern(pattern, groups, severity_map, defaults, opts)
```

The function allows to parse the linter's output using a Lua regular expression pattern.

- pattern: The regular expression pattern applied on each line of the output
- groups: The groups specified by the pattern

Available groups:

- `lnum`
- `end_lnum`
- `col`
- `end_col`
- `message`
- `file`
- `severity`
- `code`

The order of the groups must match the order of the captures within the pattern.
An example:

```lua
local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'lnum', 'col', 'code', 'message' }
```

- severity: A mapping from severity codes to diagnostic codes

``` lua
default_severity = {
['error'] = vim.diagnostic.severity.ERROR,
['warning'] = vim.diagnostic.severity.WARN,
['information'] = vim.diagnostic.severity.INFO,
['hint'] = vim.diagnostic.severity.HINT,
}
```

- defaults: The defaults diagnostic values

``` lua
defaults = {["source"] = "mylint-name"}
```

- opts: Additional options

  - `end_col_offset`: offset added to `end_col`. Defaults to `-1`, assuming
    that the end-column position is exclusive.


## Customize built-in linter parameters

You can import a linter and modify its properties. An example:

```lua
local phpcs = require('lint').linters.phpcs
phpcs.args = {
  '-q',
  -- <- Add a new parameter here
  '--report=json',
  '-'
}
```


## Alternatives

- [null-ls.nvim][null-ls]
- [Ale][1]
- [efm-langserver][6]
- [diagnostic-languageserver][7]


## Development ☢️


### Run tests

Running tests requires [plenary.nvim][plenary] to be checked out in the parent directory of *this* repository, as well as `python` resolvable via PATH.
You can then run:

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
```

Or if you want to run a single test file:

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/vale_spec.lua {minimal_init = 'tests/minimal.vim'}"
```


[1]: https://github.com/dense-analysis/ale
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/wbthomason/packer.nvim
[5]: https://languagetool.org/
[6]: https://github.com/mattn/efm-langserver
[7]: https://github.com/iamcco/diagnostic-languageserver
[8]: https://github.com/errata-ai/vale
[10]: https://www.shellcheck.net/
[11]: http://mypy-lang.org/
[12]: https://www.html-tidy.org/
[13]: https://flake8.pycqa.org/
[14]: https://github.com/mgechev/revive
[15]: https://pylint.org/
[16]: https://golangci-lint.run/
[17]: https://inko-lang.org/
[18]: https://github.com/codespell-project/codespell
[19]: https://github.com/mpeterv/luacheck
[20]: https://www.nongnu.org/chktex
[21]: https://github.com/Vimjas/vint
[22]: https://github.com/danmar/cppcheck/
[23]: https://clang.llvm.org/extra/clang-tidy/
[24]: https://github.com/clj-kondo/clj-kondo
[25]: https://github.com/eslint/eslint
[26]: https://github.com/DavidAnson/markdownlint
[27]: https://github.com/testdouble/standard
[28]: https://github.com/hadolint/hadolint
[29]: https://github.com/stylelint/stylelint
[30]: https://github.com/KDE/clazy
[31]: https://github.com/Kampfkarren/selene
[32]: https://github.com/ndmitchell/hlint
[33]: https://github.com/NerdyPepper/statix
[34]: https://www.mathworks.com/help/matlab/ref/mlint.html
[35]: https://github.com/david-a-wheeler/flawfinder
[36]: https://github.com/streetsidesoftware/cspell/tree/main/packages/cspell
[37]: https://github.com/mantoni/eslint_d.js
[null-ls]: https://github.com/jose-elias-alvarez/null-ls.nvim
[plenary]: https://github.com/nvim-lua/plenary.nvim
[ansible-lint]: https://docs.ansible.com/lint.html
[pcs-docs]: https://pycodestyle.pycqa.org/en/latest/
[pydocstyle]: https://www.pydocstyle.org/en/stable/
[checkstyle]: https://checkstyle.sourceforge.io/
[jshint]: https://jshint.com/
[jsonlint]: https://github.com/zaach/jsonlint
[rflint]: https://github.com/boakley/robotframework-lint
[robocop]: https://github.com/MarketSquare/robotframework-robocop
[vulture]: https://github.com/jendrikseipp/vulture
[yamllint]: https://github.com/adrienverge/yamllint
[cpplint]: https://github.com/cpplint/cpplint
[proselint]: https://github.com/amperser/proselint
[cmakelint]: https://github.com/cmake-lint/cmake-lint
[rstcheck]: https://github.com/myint/rstcheck
[rstlint]: https://github.com/twolfson/restructuredtext-lint
[ktlint]: https://github.com/pinterest/ktlint
[phpcs]: https://github.com/squizlabs/PHP_CodeSniffer
[psalm]: https://psalm.dev/
[lacheck]: https://www.ctan.org/tex-archive/support/lacheck
[credo]: https://github.com/rrrene/credo
[glslc]: https://github.com/google/shaderc
[rubocop]: https://github.com/rubocop/rubocop
[dxc]: https://github.com/microsoft/DirectXShaderCompiler
[cfn-lint]: https://github.com/aws-cloudformation/cfn-lint
[fennel]: https://github.com/bakpakin/Fennel
[nix]: https://github.com/NixOS/nix
[ruby]: https://github.com/ruby/ruby
[npm-groovy-lint]: https://github.com/nvuillam/npm-groovy-lint
[nagelfar]: https://nagelfar.sourceforge.net/
[oelint-adv]: https://github.com/priv-kweihmann/oelint-adv
[cfn_nag]: https://github.com/stelligent/cfn_nag
[ruff]: https://github.com/charliermarsh/ruff
[janet]: https://github.com/janet-lang/janet
