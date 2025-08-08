-- functions
--- @param mode string|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? vim.keymap.set.Opts
local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent or true
    vim.keymap.set(mode, lhs, rhs, opts)
end

local command = vim.api.nvim_create_user_command
local autocommand = vim.api.nvim_create_autocmd

-- configs
vim.o.autoindent = true
vim.o.colorcolumn = "121"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.expandtab = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.incsearch = true
vim.o.jumpoptions = "stack,view"
vim.o.mouse = ""
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.splitright = true
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.winborder = "rounded"
vim.o.wrap = false
vim.opt.fillchars:append(",eob: ")

vim.diagnostic.config({
    float = { source = true },
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_lines = false,
    virtual_text = true,
})

-- lsp
vim.lsp.enable({
    "basedpyright",
    "dprint",
    "golangci_lint_ls",
    "gopls",
    "groovyls",
    "lua_ls",
    "nil_ls",
    "nixd",
    "rust_analyzer",
    "taplo",
    "tinymist",
})

vim.lsp.inlay_hint.enable(true)

-- autocommands
local buf_easy_close = function(buf)
    vim.bo[buf].buflisted = false
    vim.keymap.set("n", "q", ":close<cr>", { buffer = buf, silent = true })
end

autocommand("FileType", {
    -- easy close
    pattern = {
        "help",
        "man",
        "checkhealth",
    },
    callback = function(event)
        buf_easy_close(event.buf)
    end
})

autocommand("TextYankPost", {
    -- highlight on yank
    callback = function()
        vim.hl.on_yank()
    end
})

-- autocommand("FileType", {
--     -- set wrap for specific files
--     pattern = {
--         "markdown",
--         "typst"
--     },
--     callback = function()
--         vim.opt_local.textwidth = 100
--         vim.opt_local.columns = 100
--         vim.opt_local.wrap = true
--         vim.opt_local.linebreak = true
--         vim.opt_local.breakindent = true
--         vim.opt_local.showbreak = "↪ "
--         vim.opt_local.colorcolumn = ""
--     end
-- })

autocommand("FileType", {
    -- set indent for specific files
    pattern = {
        "nix"
    },
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        vim.bo.shiftwidth = 2
    end
})

autocommand("VimLeave", { command = "silent !zellij action switch-mode normal" })

-- commands
command("ZellijPaneNew", "silent !zellij action new-pane", {})
command("ZellijTabNew", "silent !zellij action new-tab", {})

-- keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- map("n", "<leader> ", ":lua MiniPick.builtin.files({ tool = 'fd' })<cr>", { desc = "Find files" })
map({ "n", "x", "v" }, "Y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "x", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

map({ "n", "x" }, "<Up>", "<Nop>", { desc = "Disable Up arrow" })
map({ "n", "x" }, "<Down>", "<Nop>", { desc = "Disable Down arrow" })
map({ "n", "x" }, "<Left>", "<Nop>", { desc = "Disable Left arrow" })
map({ "n", "x" }, "<Right>", "<Nop>", { desc = "Disable Right arrow" })

-- map("n", "<leader>fg", ":lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>", { desc = "Find grep" })
-- map("n", "<leader>fb", ":lua MiniExtra.pickers.buf_lines(nil, { tool = 'rg' })<cr>", { desc = "Find in buffers" })
-- map("n", "<leader>fh", ":lua MiniExtra.pickers.git_hunks(nil, { tool = 'rg' })<cr>", { desc = "Find hunks" })
-- map("n", "<leader>fd", ":lua MiniExtra.pickers.diagnostic(nil, { tool = 'rg' })<cr>", { desc = "Find diagnostics" })
-- map("n", "<leader>fv", ":lua MiniPick.builtin.help({ tool = 'rg' })<cr>", { desc = "Find vim help" })

map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP goto definition" })
map("n", "<leader>lv", ":vsplit | lua vim.lsp.buf.definition()<CR>", { desc = "LSP goto definition in vertical split" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP rename" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "LSP hover" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP format" })

-- map("n", "<A-h>", ":ZellijNavigateLeftTab<cr>", { desc = "Navigate left" })
-- map("n", "<A-j>", ":ZellijNavigateDown<cr>", { desc = "Navigate down" })
-- map("n", "<A-k>", ":ZellijNavigateUp<cr>", { desc = "Navigate up" })
-- map("n", "<A-l>", ":ZellijNavigateRightTab<cr>", { desc = "Navigate right" })

-- map("n", "<leader>gh", ":lua MiniGit.show_at_cursor()<cr>", { desc = "Git history" })
-- map("n", "<leader>gb", ":vertical Git blame -- %<cr>", { desc = "Git blame" })
-- map("n", "<leader>gd", ":vertical Git diff -- %<cr>", { desc = "Git diff" })
-- map("n", "<leader>gs", ":vertical Git status<cr>", { desc = "Git status" })

-- plugins

require("lazy").setup({
    -- disable lazy's update / install features since nix handles that part
    rocks = { enabled = false },
    pkg = { enabled = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    install = { missing = false, colorscheme = { 'onedark' } },
    spec = {
        {
            name = "onedarkpro",
            dir = P["onedarkpro.nvim"],
            priority = 1000
        },
        {
            name = "mini.files",
            dir = P["mini.files"]
        },
    }
})
