require("blink.cmp").setup({
    snippets = { preset = "mini_snippets" },
    signature = { enabled = true },
    appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
    },
    keymap = {
        preset = "super-tab",
    },
    cmdline = {
        completion = {
            menu = { auto_show = true },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = true
                }
            }
        },
        keymap = {
            ["<CR>"] = { "accept_and_enter", "fallback" }
        }
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
            cmdline = {
                min_keyword_length = 0
            }
        },
    },
    completion = {
        accept = {
            auto_brackets = {
                enabled = true
            }
        },
        menu = {
            scrolloff = 1,
            scrollbar = false,
            draw = {
                columns = {
                    { "kind_icon" },
                    { "label",      "label_description", gap = 1 },
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
        },
        list = {
            selection = {
                preselect = false,
                auto_insert = true
            }
        },
    },
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = { "exact", "score", "sort_text" }
    }
})
