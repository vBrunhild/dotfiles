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

-- navigation
map("n", "<A-Left>", "<C-w>h", { desc = "Move to left split" })
