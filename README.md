# nvim-lint

A asynchronous linter plugin for Neovim (>= 0.5) complementary to the
built-in Language Server Protocol support.

It uses the same API to report diagnostics as the language server client
built-in to neovim would do. Any customizations you did for
`vim.lsp.diagnostic` apply for this plugin as well.


## Motivation & Goals

With [ale][1] we already got an asynchronous linter, why write yet another one?

Because [ale][1] is a full blown linter including a language server client with
its own commands and functions.


`nvim-lint` is for cases where you use the language server protocol client
built into neovim for 90% of the cases, but you want something to fill the
remaining gaps for languages where there is no good language server
implementation or where the diagnostics reporting of the language server is
inadequate and a better standalone linter exists.


## MVP

- [ ] Write the rest of the readme
- [ ] Finalize linter interface
- [ ] Include some linters for languages with a lack of good language servers
- [ ] Debounce linting


## Installation

- Requires [Neovim HEAD/nightly][2]
- `nvim-lint` is a plugin. Install it like any other Neovim plugin.
  - If using [vim-plug][3]: `Plug 'mfussenegger/nvim-lint'`
  - If using [packer.nvim][4]: `use 'mfussenegger/nvim-lint'`


## Usage

TODO


## Available Linters

- [Languagetool][5]
  - markdown
  - text


## Custom Linters

TODO


## Alternatives

- [Ale][1]
- [efm-langserver][6]
- [diagnostic-languageserver][7]


[1]: https://github.com/dense-analysis/ale
[2]: https://github.com/neovim/neovim/releases/tag/nightly
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/wbthomason/packer.nvim
[5]: https://languagetool.org/
[6]: https://github.com/mattn/efm-langserver
[7]: https://github.com/iamcco/diagnostic-languageserver
