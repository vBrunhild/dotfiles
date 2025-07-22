require("blink.cmp").setup({
    snippets = { preset = "luasnip" },
    signature = { enabled = true },
    appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
    },
    keymap = {
        preset = 'super-tab',
    },
    cmdline = {
        completion = {
            menu = { auto_show = true },
            list = { selection = { preselect = false } }
        },
        keymap = {
            ["<CR>"] = { "accept_and_enter", "fallback" }
        }
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
            cmdline = {
                min_keyword_length = 2
            }
        },
    },
    completion = {
        menu = {
            border = nil,
            scrolloff = 1,
            scrollbar = false,
            draw = {
                columns = {
                    { "kind_icon" },
                    { "label", "label_description", gap = 1 },
                    { "kind" },
                    { "source_name" }
                }
            }
        },

        documentation = {
            window = {
                scrollbar = false,
                winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
            },
            auto_show = true,
            auto_show_delay_ms = 500
        }
    }
})

