local minitrailspace = require("mini.trailspace")

local buf_easy_close = function(buf)
    vim.bo[buf].buflisted = false
    vim.keymap.set("n", "q", ":close<cr>", { buffer = buf, silent = true })
end

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
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniGitCommandSplit",
    callback = function(event)
        buf_easy_close(event.buf)
        if event.data.git_subcommand ~= "blame" then return end

        -- Align blame output with source
        local win_src = event.data.win_source
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
        "checkhealth",
    },
    callback = function(event)
        buf_easy_close(event.buf)
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

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end
})
