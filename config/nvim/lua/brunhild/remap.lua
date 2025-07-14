vim.g.mapleader = " "

vim.keymap.set("n", "<leader> ", vim.cmd.Ex)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

