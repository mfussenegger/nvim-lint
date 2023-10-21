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
au BufWritePost * lua require('lint').try_lint()
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

| Tool                               | Linter name            |
| ---------------------------------- | ---------------------  |
| Set via `makeprg`                  | `compiler`             |
| [actionlint][actionlint]           | `actionlint`           |
| [alex][alex]                       | `alex`                 |
| [ansible-lint][ansible-lint]       | `ansible_lint`         |
| [bandit][bandit]                   | `bandit`               |
| [bean-check][bean-check]           | `bean_check`           |
| [biomejs][biomejs]                 | `biomejs`              |
| [blocklint][blocklint]             | `blocklint`            |
| [buf_lint][buf_lint]               | `buf_lint`             |
| [buildifier][buildifier]           | `buildifier`           |
| [cfn-lint][cfn-lint]               | `cfn_lint`             |
| [cfn_nag][cfn_nag]                 | `cfn_nag`              |
| [checkpatch.pl][checkpatch]        | `checkpatch`           |
| [checkstyle][checkstyle]           | `checkstyle`           |
| [chktex][20]                       | `chktex`               |
| [clang-tidy][23]                   | `clangtidy`            |
| [clazy][30]                        | `clazy`                |
| [clj-kondo][24]                    | `clj-kondo`            |
| [cmakelint][cmakelint]             | `cmakelint`            |
| [codespell][18]                    | `codespell`            |
| [commitlint][commitlint]           | `commitlint`           |
| [cppcheck][22]                     | `cppcheck`             |
| [cpplint][cpplint]                 | `cpplint`              |
| [credo][credo]                     | `credo`                |
| [cspell][36]                       | `cspell`               |
| [curlylint][curlylint]             | `curlylint`            |
| [deno][deno]                       | `deno`                 |
| [djlint][djlint]                   | `djlint`               |
| [dotenv-linter][dotenv-linter]     | `dotenv_linter`        |
| [editorconfig-checker][ec]         | `editorconfig-checker` |
| [erb-lint][erb-lint]               | `erb_lint`             |
| [ESLint][25]                       | `eslint`               |
| [eslint_d][37]                     | `eslint_d`             |
| [fennel][fennel]                   | `fennel`               |
| [Flake8][13]                       | `flake8`               |
| [flawfinder][35]                   | `flawfinder`           |
| [gdlint (gdtoolkit)][gdlint]       | `gdlint`               |
| [gitlint][gitlint]                 | `gitlint`              |
| [Golangci-lint][16]                | `golangcilint`         |
| [glslc][glslc]                     | `glslc`                |
| [DirectX Shader Compiler][dxc]     | `dxc`                  |
| [hadolint][28]                     | `hadolint`             |
| [hlint][32]                        | `hlint`                |
| [HTML Tidy][12]                    | `tidy`                 |
| [Inko][17]                         | `inko`                 |
| [janet][janet]                     | `janet`                |
| [jshint][jshint]                   | `jshint`               |
| [jsonlint][jsonlint]               | `jsonlint`             |
| [ktlint][ktlint]                   | `ktlint`               |
| [lacheck][lacheck]                 | `lacheck`              |
| [Languagetool][5]                  | `languagetool`         |
| [luacheck][19]                     | `luacheck`             |
| [markdownlint][26]                 | `markdownlint`         |
| [mlint][34]                        | `mlint`                |
| [Mypy][11]                         | `mypy`                 |
| [Nix][nix]                         | `nix`                  |
| [npm-groovy-lint][npm-groovy-lint] | `npm-groovy-lint`      |
| [oelint-adv][oelint-adv]           | `oelint-adv`           |
| [perlcritic][perlcritic]           | `perlcritic`           |
| [perlimports][perlimports]         | `perlimports`          |
| [php][php]                         | `php`                  |
| [phpcs][phpcs]                     | `phpcs`                |
| [phpmd][phpmd]                     | `phpmd`                |
| [phpstan][phpstan]                 | `phpstan`              |
| [proselint][proselint]             | `proselint`            |
| [psalm][psalm]                     | `psalm`                |
| [puppet-lint][puppet-lint]         | `puppet-lint`          |
| [pycodestyle][pcs-docs]            | `pycodestyle`          |
| [pydocstyle][pydocstyle]           | `pydocstyle`           |
| [Pylint][15]                       | `pylint`               |
| [Revive][14]                       | `revive`               |
| [rflint][rflint]                   | `rflint`               |
| [robocop][robocop]                 | `robocop`              |
| [rstcheck][rstcheck]               | `rstcheck`             |
| [rstlint][rstlint]                 | `rstlint`              |
| [RPM][rpm]                         | `rpmspec`              |
| [Ruby][ruby]                       | `ruby`                 |
| [RuboCop][rubocop]                 | `rubocop`              |
| [Ruff][ruff]                       | `ruff`                 |
| [Selene][31]                       | `selene`               |
| [ShellCheck][10]                   | `shellcheck`           |
| [snyk][snyk]                       | `snyk_iac`             |
| [sqlfluff][sqlfluff]               | `sqlfluff`             |
| [standardjs][standardjs]           | `standardjs`           |
| [StandardRB][27]                   | `standardrb`           |
| [statix check][33]                 | `statix`               |
| [stylelint][29]                    | `stylelint`            |
| [Solhint][solhint]                 | `solhint`              |
| [Nagelfar][nagelfar]               | `nagelfar`             |
| [Vale][8]                          | `vale`                 |
| [Verilator][verilator]             | `verilator`            |
| [vint][21]                         | `vint`                 |
| [vulture][vulture]                 | `vulture`              |
| [woke][woke]                       | `woke`                 |
| [write-good][write-good]           | `write_good`           |
| [yamllint][yamllint]               | `yamllint`             |
| [tfsec][tfsec]                     | `tfsec`                |
| [trivy][trivy]                     | `trivy`                |

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

  - `lnum_offset`: Added to `lnum`. Defaults to 0
  - `end_lnum_offset`: Added to `end_lnum`. Defaults to 0
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

- [Ale][1]
- [efm-langserver][6]
- [diagnostic-languageserver][7]


## Development ☢️


### Run tests

Running tests requires [busted][busted].

See [neorocks][neorocks] or [Using Neovim as Lua interpreter with
Luarocks][neovim-luarocks] for installation instructions.

```bash
busted tests/
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
[neorocks]: https://github.com/nvim-neorocks/neorocks
[neovim-luarocks]: https://zignar.net/2023/01/21/using-luarocks-as-lua-interpreter-with-luarocks/
[busted]: https://lunarmodules.github.io/busted/
[ansible-lint]: https://docs.ansible.com/lint.html
[pcs-docs]: https://pycodestyle.pycqa.org/en/latest/
[pydocstyle]: https://www.pydocstyle.org/en/stable/
[checkpatch]: https://docs.kernel.org/dev-tools/checkpatch.html
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
[php]: https://www.php.net/
[phpcs]: https://github.com/squizlabs/PHP_CodeSniffer
[phpmd]: https://phpmd.org/
[phpstan]: https://phpstan.org/
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
[ruff]: https://github.com/astral-sh/ruff
[janet]: https://github.com/janet-lang/janet
[bandit]: https://bandit.readthedocs.io/en/latest/
[bean-check]: https://beancount.github.io/docs/running_beancount_and_generating_reports.html#bean-check
[curlylint]: https://www.curlylint.org/
[sqlfluff]: https://github.com/sqlfluff/sqlfluff
[verilator]: https://verilator.org/guide/latest/
[actionlint]: https://github.com/rhysd/actionlint
[buf_lint]: https://github.com/bufbuild/buf
[erb-lint]: https://github.com/shopify/erb-lint
[tfsec]: https://github.com/aquasecurity/tfsec
[trivy]: https://github.com/aquasecurity/trivy
[djlint]: https://djlint.com/
[buildifier]: https://github.com/bazelbuild/buildtools/tree/master/buildifier
[solhint]: https://protofire.github.io/solhint/
[perlimports]: https://github.com/perl-ide/App-perlimports
[perlcritic]: https://github.com/Perl-Critic/Perl-Critic
[gdlint]: https://github.com/Scony/godot-gdscript-toolkit
[rpm]: https://rpm.org
[ec]: https://github.com/editorconfig-checker/editorconfig-checker
[deno]: https://github.com/denoland/deno
[standardjs]: https://standardjs.com/
[biomejs]: https://github.com/biomejs/biome
[commitlint]: https://commitlint.js.org
[alex]: https://alexjs.com/
[blocklint]: https://github.com/PrincetonUniversity/blocklint
[woke]: https://docs.getwoke.tech/
[write-good]: https://github.com/btford/write-good
[dotenv-linter]: https://dotenv-linter.github.io/
[puppet-lint]: https://github.com/puppetlabs/puppet-lint
[snyk]: https://github.com/snyk/cli
[gitlint]: https://github.com/jorisroovers/gitlint
