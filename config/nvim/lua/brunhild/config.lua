vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

-- indentation stuff
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

local filetypes_2_space = {
    "nix"
}

vim.api.nvim_create_autocmd("FileType", {
    --group = "IndentationSettings",
    pattern = filetypes_2_space,
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
    desc = "Set 2-space indentation for specific file types"
})

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
    "nixd",
    "nil",
    "rust_analyzer",
    "lua_ls"
})

vim.lsp.inlay_hint.enable(true)

