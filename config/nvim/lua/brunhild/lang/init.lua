require("brunhild.lang.rust")
require("brunhild.lang.go")
require("brunhild.lang.nix")
require("brunhild.lang.python")

vim.lsp.enable({
    'rust_analyzer',
    'gopls',
    'pyright',
    'nixd',
    'nil'
})

vim.lsp.inlay_hint.enable(true)

