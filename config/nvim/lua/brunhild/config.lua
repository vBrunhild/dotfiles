vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.colorcolumn = "121"
vim.opt.updatetime = 100

vim.o.completeopt = "menuone,noinsert,noselect"

-- fold stuff
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99

