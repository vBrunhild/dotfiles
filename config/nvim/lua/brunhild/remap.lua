local wk = require("which-key")

vim.g.mapleader = " "

wk.add({
    { "<leader> ", vim.cmd.Ex }
})

vim.keymap.set("n", "<leader> ", vim.cmd.Ex)

