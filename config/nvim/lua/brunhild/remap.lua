local wk = require("which-key")

vim.g.mapleader = " "

wk.add({
    { "<leader> ", vim.cmd.Ex, desc = "Opens neovim explorer." }
})

