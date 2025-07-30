vim.loader.enable()

vim.o.signcolumn = "yes"
-- vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.colorcolumn = "121"
-- vim.o.updatetime = 100
vim.o.scrolloff = 10
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.jumpoptions = "stack,view"
vim.o.incsearch = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.wrap = false
vim.o.winborder = "rounded"
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.mouse = ""
vim.opt.fillchars:append(",eob: ")

vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = true,
    underline = true,
    --update_in_insert = false,
    severity_sort = true,
    float = {
        source = true
    }
})

-- lsp
vim.lsp.enable({
    "basedpyright",
    "gopls",
    "golangci_lint_ls",
    "nixd",
    "nil_ls",
    "rust_analyzer",
    "lua_ls",
    "taplo",
    "dprint",
    "tinymist",
    "groovyls"
})

vim.lsp.inlay_hint.enable(true)
