vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

-- indentation stuff
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.colorcolumn = "121"
vim.opt.updatetime = 100

vim.o.completeopt = "menuone,noinsert,noselect"

-- fold stuff
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99

vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = true,
    underline = true,
    --update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true
    }
})

vim.lsp.enable({
    "basedpyright",
    "gopls",
    "golangci_lint_ls",
    "nixd",
    "nil_ls",
    "rust_analyzer",
    "lua_ls",
    "taplo",
    "dprint"
})

vim.lsp.inlay_hint.enable(true)

