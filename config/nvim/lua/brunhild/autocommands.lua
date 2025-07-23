local minifiles = require("mini.files")

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argv(0) == "" then
            require("telescope.builtin").find_files()
        end
    end
})

local map_to_buffer = function(buffer, lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local buffer = args.data.buf_id

        map_to_buffer(buffer, "<A-Right>", function() minifiles.go_in({ close_on_file = true }) end, "Go in file")
        map_to_buffer(buffer, "<A-Left>", minifiles.go_out, "Go out of file")
    end
})

