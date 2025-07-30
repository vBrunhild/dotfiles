local minifiles = require("mini.files")

local map = vim.keymap.set

-- leader
vim.g.mapleader = " "

local minifiles_toggle = function()
    if not minifiles.close() then minifiles.open(vim.api.nvim_buf_get_name(0), false) end
end

map("n", "<leader> ", minifiles_toggle, { desc = "Open explorer" })
map({ "n", "x", "v" }, "Y", '"+y', { desc = "Yank to clipboard" })

-- force me to use hjkl
map({ "n", "x" }, "<Up>", "<Nop>", { silent = true, desc = "Disable Up arrow" })
map({ "n", "x" }, "<Down>", "<Nop>", { silent = true, desc = "Disable Down arrow" })
map({ "n", "x" }, "<Left>", "<Nop>", { silent = true, desc = "Disable Left arrow" })
map({ "n", "x" }, "<Right>", "<Nop>", { silent = true, desc = "Disable Right arrow" })

-- write
map("n", "<leader>ww", ":w<cr>", { desc = "Write" })
map("n", "<leader>wd", ":w<cr>:lua MiniBufremove.delete()<cr>", { desc = "Write buf delete" })
map("n", "<leader>wq", ":wqa<cr>", { desc = "Write quit" })

-- buffers
map("n", "<leader>bd", ":lua MiniBufremove.delete()<cr>", { desc = "Buffer delete" })

-- find
map("n", "<leader>ff", ":lua MiniPick.builtin.files({ tool = 'rg' })<cr>", { desc = "Find files" })
map("n", "<leader>fg", ":lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>", { desc = "Find grep" })
map("n", "<leader>fb", ":lua MiniPick.builtin.buffers()<cr>", { desc = "Find buffers" })
map("n", "<leader>fh", ":lua MiniExtra.pickers.git_hunks()<cr>", { desc = "Find hunks" })
map("n", "<leader>fd", ":lua MiniExtra.pickers.diagnostic()<cr>", { desc = "Find diagnostics" })
map("n", "<leader>fv", ":lua MiniPick.builtin.help({ tool = 'rg' })<cr>", { desc = "Find vim help"})

-- lsp
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP goto definition" })
map("n", "<leader>lv", ":vsplit | lua vim.lsp.buf.definition()<CR>", { desc = "LSP goto definition in vertical split" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP rename" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "LSP hover" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP format" })

-- navigation / fine... I will hjkl
map({ "n", "i" }, "<A-h>", ":ZellijNavigateLeftTab<cr>", { desc = "Navigate left" })
map({ "n", "i" }, "<A-j>", ":ZellijNavigateDown<cr>", { desc = "Navigate down" })
map({ "n", "i" }, "<A-k>", ":ZellijNavigateUp<cr>", { desc = "Navigate up" })
map({ "n", "i" }, "<A-l>", ":ZellijNavigateRightTab<cr>", { desc = "Navigate right" })

-- git
map("n", "<leader>gh", ":lua MiniGit.show_at_cursor()<cr>", { desc = "Git history" })
map("n", "<leader>gb", ":vertical Git blame -- %<cr>", { desc = "Git blame" })
map("n", "<leader>gd", ":vertical Git diff -- %<cr>", { desc = "Git diff" })
map("n", "<leader>gs", ":vertical Git status<cr>", { desc = "Git status" })

-- general
map({ "n", "o", "x" }, "<C-a>", "ggVG", { desc = "Select all" })
map("v", "<", "<gv")
map("v", ">", ">gv")
