local minifiles = require("mini.files")
local minitrailspace = require("mini.trailspace")

local map_to_buffer = function(buffer, lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
end

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

-- Align git blame
vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniGitCommandSplit',
    callback = function(au_data)
        if au_data.data.git_subcommand ~= 'blame' then return end

        -- Align blame output with source
        local win_src = au_data.data.win_source
        vim.wo.wrap = false
        vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
        vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

        -- Bind both windows so that they scroll together
        vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
    end
})

-- Easy close
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "help",
        "man",
        "checkhealth"
    },
    callback = function (event)
        vim.bo[event.buf].buflisted = false
        map_to_buffer(event.buf, "q", ":close<Cr>", "Close")
    end
})

-- Start linter on opening or saving file
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*.groovy",
    callback = function()
        require("lint").try_lint()
        vim.api.nvim_create_user_command("GroovyLintFix", "silent !npm-groovy-lint --fix %", {})
        vim.api.nvim_create_user_command("GroovyLintFormat", "silent !npm-groovy-lint --format %", {})
    end
})

-- End minisnips session on final tabstop
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniSnippetsSessionJump",
    callback = function(args)
        if args.data.tabstop_to == '0' then
            require("mini.snippets").session.stop()
        end
    end
})
