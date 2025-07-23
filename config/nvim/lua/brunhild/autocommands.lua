local telescope = require("telescope.builtin")
local minifiles = require("mini.files")
local minitrailspace = require("mini.trailspace")

local map_to_buffer = function(buffer, lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
end

-- Supposed to open vim with Telescope but somehow doesn't work?
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argv(0) == "" then
            -- minifiles.close() DOESN'T WORK!
            telescope.find_files()
        end
    end
})

-- This lets me navigate minifiles hjkl is stupid
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local buffer = args.data.buf_id

        map_to_buffer(buffer, "<A-Right>", function() minifiles.go_in({ close_on_file = true }) end, "Go in file")
        map_to_buffer(buffer, "<A-Left>", minifiles.go_out, "Go out of file")
    end
})

-- Auto trim last lines on bw
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        minitrailspace.trim_last_lines()
    end
})

-- Zellij compat
vim.api.nvim_create_autocmd("VimLeave", {
    command = "silent !zellij action switch-mode normal"
})
