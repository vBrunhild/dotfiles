local wk = require("which-key")
local telescope = require("telescope.builtin")

vim.g.mapleader = " "

wk.add({
    { "<leader> ", vim.cmd.Ex, desc = "Opens neovim explorer" },

    -- telescope
    { "<leader>ff", telescope.find_files, desc = "Telescope find files" },
    { "<leader>fg", telescope.git_files, desc = "Telescope find git files" },

    -- lsp
    { "<leader>ld", vim.lsp.buf.signature_help, desc = "Signature documentation" },
    { "<leader>lr", vim.lsp.buf.rename, desc = "Rename all references" },
    { "<leader>lv", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", desc = "Goto definition in vertical split" }
})

