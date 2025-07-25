local minifiles = require("mini.files")
local origami = require("origami")
local substitute = require("substitute")

local map = vim.keymap.set

vim.g.mapleader = " "

local minifiles_toggle = function()
    if not minifiles.close() then minifiles.open(vim.api.nvim_buf_get_name(0), false) end
end

map("n", "<leader> ", minifiles_toggle, { desc = "Open explorer" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("n", "<Left>", function() origami.h() end)
map("n", "<Right>", function() origami.l() end)

-- find
map("n", "<leader>ff", "<cmd>lua MiniPick.builtin.files({ tool = 'rg' })<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>", { desc = "Find grep" })
map("n", "<leader>fb", "<cmd>lua MiniPick.builtin.buffers()<cr>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>lua MiniExtra.pickers.git_hunks()<cr>", { desc = "Find hunks" })
map("n", "<leader>fd", "<cmd>lua MiniExtra.pickers.diagnostic()", { desc = "Find diagnostics" })

-- lsp
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP goto definition" })
map("n", "<Leader>lv", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", { desc = "LSP goto definition in vertical split" })
map("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "LSP rename" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "LSP hover" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })

-- navigation / hjkl wtf?
map("n", "<A-Left>", "<cmd>ZellijNavigateLeftTab<cr>", { desc = "Navigate left" })
map("n", "<A-Right>", "<cmd>ZellijNavigateRightTab<cr>", { desc = "Navigate right" })
map("n", "<A-Up>", "<cmd>ZellijNavigateUp<cr>", { desc = "Navigate up" })
map("n", "<A-Down>", "<cmd>ZellijNavigateDown<cr>", { desc = "Navigate down" })
map("n", "<C-Left>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<C-Right>", ":bprevious<CR>", { desc = "Previous buffer" })

-- substitute
map("n", "s", substitute.operator, { desc = "Substitution operator" })
map("n", "ss", substitute.line, { desc = "Substitute line" })
map("n", "S", substitute.eol, { desc = "Substitute eol" })
map("x", "s", substitute.visual, { desc = "Substitute visual" })

-- git
map("n", "<leader>gs", ":lua MiniGit.show_at_cursor()<cr>", { desc = "Git show" })
map("n", "<leader>gb", ":vertical Git blame -- %<cr>", { desc = "Git blame" })

-- the solution to my indentation problems
map("v", "<", "<gv")
map("v", ">", ">gv")
