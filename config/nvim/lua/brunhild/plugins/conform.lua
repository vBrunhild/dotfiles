require("conform").setup({
    formatters = {
        dprint = {
            command = "dprint",
            args = { "fmt", "--stdin", "$FILENAME" },
            stdin = true
        }
    },

    formatters_by_ft = {
        json = { "dprint" },
        jsonc = { "dprint" }
    }
})

vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.lin2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() }
        }
    end

    require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

