local minifiles = require("mini.files")
local telescope = require("telescope.builtin")

local map = vim.keymap.set

vim.g.mapleader = " "

local minifiles_toggle = function()
    if not minifiles.close() then minifiles.open(vim.api.nvim_buf_get_name(0), false) end
end

map("n", "<leader> ", minifiles_toggle, { desc = "Open explorer" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })

-- telescope
map("n", "<leader>ff", telescope.find_files, { desc = "Telescope find files" })
map("n", "<leader>fg", telescope.live_grep, { desc = "Telescope grep" })
map("n", "<leader>fb", telescope.buffers, { desc = "Telescope find buffers" })

-- lsp
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP goto definition" })
map("n", "<Leader>lv", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", { desc = "LSP goto definition in vertical split" })
map("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "LSP rename" })

-- navigation / hjkl wtf?
map("n", "<A-Left>", "<cmd>ZellijNavigateLeftTab<cr>", { desc = "Navigate left" })
map("n", "<A-Right>", "<cmd>ZellijNavigateRightTab<cr>", { desc = "Navigate right" })
map("n", "<A-Up>", "<cmd>ZellijNavigateUp<cr>", { desc = "Navigate up" })
map("n", "<A-Down>", "<cmd>ZellijNavigateDown<cr>", { desc = "Navigate down" })
