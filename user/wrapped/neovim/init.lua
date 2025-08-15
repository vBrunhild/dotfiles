if vim.env.PROF then
    require("snacks.profiler").startup({
        startup = {
            event = "VimEnter"
        }
    })
end

-- functions
---@class MapOpts : vim.keymap.set.Opts
---@field mode? string|string[]

---@param lhs string
---@param rhs string|function
---@param opts? MapOpts
local map = function(lhs, rhs, opts)
    opts = opts or {}
    if opts.silent == nil then
        opts.silent = true
    end
    local mode = opts.mode or "n"
    vim.keymap.set(mode, lhs, rhs, opts)
end

---comment
---@param name string
---@param command string|fun(args: vim.api.keyset.create_user_command.command_args)
---@param opts? vim.api.keyset.user_command
local command = function(name, command, opts)
    opts = opts or {}
    vim.api.nvim_create_user_command(name, command, opts)
end

local autocommand = vim.api.nvim_create_autocmd

-- configs
vim.g.clipboard = "osc52"
vim.o.autoindent = true
vim.o.colorcolumn = "121"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.expandtab = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.incsearch = true
vim.o.jumpoptions = "stack,view"
vim.o.mouse = ""
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.winborder = "rounded"
vim.o.wrap = false
vim.opt.fillchars:append(",eob: ")

vim.diagnostic.config({
    float = { source = true },
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_lines = false,
    virtual_text = true,
})

-- autocommands
local buf_easy_close = function(buf)
    vim.bo[buf].buflisted = false
    map("q", "<Cmd>close<cr>", { buffer = buf, silent = true })
end

autocommand("FileType", {
    -- easy close
    pattern = {
        "help",
        "man",
        "checkhealth",
    },
    callback = function(event)
        buf_easy_close(event.buf)
    end
})

autocommand("TextYankPost", {
    -- highlight on yank
    callback = function()
        vim.hl.on_yank()
    end
})

autocommand("FileType", {
    -- set indent for specific files
    pattern = {
        "nix"
    },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
    end
})

autocommand("VimLeave", { command = "silent !zellij action switch-mode normal" })

-- commands
command("ZellijPaneNew", "silent !zellij action new-pane")
command("ZellijTabNew", "silent !zellij action new-tab")

-- keymaps
vim.g.mapleader = " "

map("Y", '"+y', { mode = { "n", "x", "v" }, desc = "Yank to clipboard" })
map("<C-a>", "ggVG", { mode = { "n", "x", "v" }, desc = "Select all" })
map("P", "<Cmd>pu<cr>", { desc = "Paste in new line" })

map("<leader>ld", vim.lsp.buf.definition, { mode = { "n", "x" }, desc = "LSP goto definition" })
map("<leader>lr", vim.lsp.buf.rename, { mode = { "n", "x" }, desc = "LSP rename" })
map("<leader>lh", vim.lsp.buf.hover, { mode = { "n", "x" }, desc = "LSP hover" })
map("<leader>la", vim.lsp.buf.code_action, { mode = { "n", "x" }, desc = "LSP code action" })
map("<leader>lf", vim.lsp.buf.format, { mode = { "n", "x" }, desc = "LSP format" })

-- lsp
vim.lsp.config("basedpyright", {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
    },
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
            },
        },
    }
})

vim.lsp.config("dprint", {
    cmd = { 'dprint', 'lsp' },
    filetypes = {
        'json',
        'jsonc'
    },
    root_marker = { 'dprint.json', '.dprint.json', 'dprint.jsonc', '.dprint.jsonc' },
    settings = {}
})

vim.lsp.config("golangci_lint_ls", {
    default_config = {
        cmd = { 'golangci-lint-langserver' },
        filetypes = { 'go', 'gomod' },
        init_options = {
            command = { 'golangci-lint', 'run', '--output.json.path=stdout', '--show-stats=false' },
        },
        root_markers = {
            '.golangci.yml',
            '.golangci.yaml',
            '.golangci.toml',
            '.golangci.json',
            'go.work',
            'go.mod',
            '.git',
        },
        before_init = function(_, config)
            local v1
            if vim.fn.executable 'go' == 1 then
                local exe = vim.fn.exepath 'golangci-lint'
                local version = vim.system({ 'go', 'version', '-m', exe }):wait()
                v1 = string.match(version.stdout, '\tmod\tgithub.com/golangci/golangci%-lint\t')
            else
                local version = vim.system({ 'golangci-lint', 'version' }):wait()
                v1 = string.match(version.stdout, 'version v?1%.')
            end
            if v1 then
                config.init_options.command = { 'golangci-lint', 'run', '--out-format', 'json' }
            end
        end,
    }
})

vim.lsp.config("gopls", {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = {
        '.golangci.yml',
        '.golangci.yaml',
        '.golangci.toml',
        '.golangci.json',
        'go.work',
        'go.mod',
        '.git',
    },
    settings = {
        gopls = {
            codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true
            },
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterValues = true,
                rangeVariableTypes = true
            },
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                unreachable = true,
                modernize = true,
                stylecheck = true,
                appends = true,
                asmdecl = true,
                assign = true,
                atomic = true,
                bools = true,
                buildtag = true,
                cgocall = true,
                composite = true,
                contextcheck = true,
                deba = true,
                atomicalign = true,
                composites = true,
                copylocks = true,
                deepequalerrors = true,
                defers = true,
                deprecated = true,
                directive = true,
                embed = true,
                errorsas = true,
                fillreturns = true,
                framepointer = true,
                gofix = true,
                hostport = true,
                infertypeargs = true,
                lostcancel = true,
                httpresponse = true,
                ifaceassert = true,
                loopclosure = true,
                nilfunc = true,
                nonewvars = true,
                noresultvalues = true,
                printf = true,
                shadow = true,
                shift = true,
                sigchanyzer = true,
                simplifycompositelit = true,
                simplifyrange = true,
                simplifyslice = true,
                slog = true,
                sortslice = true,
                stdmethods = true,
                stdversion = true,
                stringintconv = true,
                structtag = true,
                testinggoroutine = true,
                tests = true,
                timeformat = true,
                unmarshal = true,
                unsafeptr = true,
                unusedfunc = true,
                unusedresult = true,
                waitgroup = true,
                yield = true,
                unusedvariable = true
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git" },
            semanticTokens = true
        }
    }
})

vim.lsp.config("groovyls", {
    cmd = { 'groovy-language-server' },
    filetypes = { 'groovy' },
    root_markers = { 'Jenkinsfile', '.git' },
})

vim.lsp.config("lua_ls", {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git'
    },
    ---@param client vim.lsp.Client
    on_init = function(client)
        local workspace = client.workspace_folders[1].name
        local luarc_exists = vim.fn.glob(workspace .. "/.luarc.json") ~= "" or
            vim.fn.glob(workspace .. "/.luarc.jsonc") ~= ""
        if luarc_exists then return end
        local config = client.config.settings.Lua
        ---@cast config table
        client.config.settings.Lua = vim.tbl_deep_extend("force", config, {
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua"
                }
                --vim.split(package.path, ";", { trimempty = true })
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    vim.api.nvim_get_runtime_file('*/myNeovimPackages/start', false)[1]
                }
            }
        })
    end,
    settings = {
        Lua = {
            hint = { enable = true }
        }
    }
})

vim.lsp.config("nil_ls", {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", "git" }
})

vim.lsp.config("nixd", {
    cmd = { 'nixd' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', 'git' }
})

vim.lsp.config("rust_analyzer", {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    capabilites = {
        experimental = {
            serverStatusNotification = true,
        }
    },
    before_init = function(init_params, config)
        if config.settings and config.settings['rust-analyzer'] then
            init_params.initializationOptions = config.settings['rust-analyzer']
        end
    end,
    ---@param client vim.lsp.Client
    ---@param bufnr integer
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
            vim.notify("Reloading cargo workspace")
            client:request("rust-analyzer/reloadWorkspace", nil, function(err)
                if err then
                    error(tostring(err))
                end
                vim.notify("Cargo workspace reloaded")
            end, bufnr)
        end, { desc = "Reload current cargo workspace" })
    end,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                buildScripts = {
                    enable = true
                }
            },
            procMacro = {
                enable = true
            },
            inlayHints = {
                typeHints = { enable = true },
                parameterHints = { enable = true },
                chainingHints = { enable = true },
                bindingModeHints = { enable = true },
                renderColons = true
            },
            check = {
                command = "clippy"
            }
        }
    }
})

vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".taplo.toml", "taplo.toml", ".git" }
})

vim.lsp.enable({
    "basedpyright",
    "dprint",
    "golangci_lint_ls",
    "gopls",
    "groovyls",
    "lua_ls",
    "nil_ls",
    "nixd",
    "rust_analyzer",
    "taplo",
    "tinymist",
})

vim.lsp.inlay_hint.enable(true)

-- plugins
if vim.env.NVIM_MINIMAL then
    -- this lets me open neovim with some configs but no plugins in case of fuck ups
    return
end

---@type lze.PluginSpec[]
require("lze").load({
    {
        "nvim-treesitter",
        lazy = vim.fn.argc(-1) == 0,
        event = "BufEnter",
        before = function()
            require("nvim-treesitter.query_predicates")
        end,
        after = function()
            ---@type TSConfig
            ---@diagnostic disable-next-line: missing-fields
            local treesitter_config = {
                auto_install = false,
                sync_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true
                }
            }
            require("nvim-treesitter.configs").setup(treesitter_config)
        end
    },
    {
        "blink.cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        after = function()
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
                        ["<CR>"] = { "accept_and_enter", "fallback" },
                        ["<Left>"] = false,
                        ["<Right>"] = false,
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
                            components = {
                                kind_icon = {
                                    text = function(ctx)
                                        local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                                        return kind_icon
                                    end,
                                    highlight = function(ctx)
                                        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                        return hl
                                    end
                                },
                                kind = {
                                    highlight = function(ctx)
                                        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                        return hl
                                    end
                                }
                            },
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
                            -- winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
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
        end
    },
    {
        "conform",
        event = { "BufEnter" },
        cmd = { "ConformInfo" },
        after = function()
            ---@type conform.setupOpts
            local conform_config = {
                formatters = {
                    dprint = {
                        command = "dprint",
                        args = { "fmt", "--stdin", "$FILENAME" },
                        stdin = true
                    },
                    ["npm-groovy-lint"] = {
                        command = "npm-groovy-lint",
                        args = { "--fix", "$FILENAME" },
                        stdin = false,
                        exit_codes = { 0, 1 },
                    },
                },
                formatters_by_ft = {
                    groovy = { "npm-groovy-lint" },
                    json = { "dprint" },
                    jsonc = { "dprint" },
                    nix = { "alejandra" },
                    rust = { "rustfmt" },
                },
                default_format_opts = {
                    lsp_format = "fallback"
                }
            }
            require("conform").setup(conform_config)
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end
    },
    {
        "friendly-snippets",
        dep_of = "blink.cmp"
    },
    {
        "mini.bufremove",
        event = "BufDelete",
        after = function() require("mini.bufremove").setup() end
    },
    {
        "mini.clue",
        event = "DeferredUIEnter",
        after = function()
            local miniclue = require("mini.clue")
            miniclue.setup({
                triggers = {
                    -- Leader triggers
                    { mode = "n", keys = "<leader>" },
                    { mode = "x", keys = "<leader>" },
                    -- Built-in completion
                    { mode = "i", keys = "<C-x>" },
                    -- `g` key
                    { mode = "n", keys = "g" },
                    { mode = "x", keys = "g" },
                    -- Marks
                    { mode = "n", keys = "'" },
                    { mode = "n", keys = "`" },
                    { mode = "x", keys = "'" },
                    { mode = "x", keys = "`" },
                    -- Registers
                    { mode = "n", keys = '"' },
                    { mode = "x", keys = '"' },
                    { mode = "i", keys = "<C-r>" },
                    { mode = "c", keys = "<C-r>" },
                    -- Window commands
                    { mode = "n", keys = "<C-w>" },
                    -- `z` key
                    { mode = "n", keys = "z" },
                    { mode = "x", keys = "z" },
                    -- jump
                    { mode = "n", keys = "[" },
                    { mode = "x", keys = "[" },
                    { mode = "n", keys = "]" },
                    { mode = "x", keys = "]" },
                    -- surround
                    { mode = "n", keys = "s" },
                    { mode = "x", keys = "s" },
                },
                clues = {
                    { mode = "n", keys = "<Leader>f", desc = "+Picker" },
                    { mode = "n", keys = "<Leader>l", desc = "+LSP" },
                    { mode = "n", keys = "<Leader>g", desc = "+Git" },
                    { mode = "n", keys = "<Leader>d", desc = "+Dap" },
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                },
                window = {
                    delay = 500,
                    config = {
                        width = "auto"
                    }
                }
            })
        end
    },
    {
        "mini.comment",
        keys = { "gc", desc = "Comment" },
        after = function() require("mini.comment").setup() end
    },
    {
        "mini.diff",
        event = "DeferredUIEnter",
        keys = {
            { "<leader>go", "<Cmd>lua MiniDiff.toggle_overlay()<cr>", silent = true, desc = "Toggle overlay" },
        },
        after = function()
            require("mini.diff").setup({
                view = {
                    style = "sign"
                }
            })
        end
    },
    {
        "mini.extra",
        dep_of = "mini.pick",
        after = function() require("mini.extra").setup() end,
    },
    {
        "mini.files",
        after = function()
            require("mini.files").setup({
                windows = {
                    max_number = 3,
                    preview = true,
                    width_focus = 35,
                    width_nofocus = 35,
                    widthpreview = 35
                }
            })
        end,
        keys = {
            { "<leader>e", "<Cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>", silent = true, desc = "File explorer" }
        }
    },
    {
        "mini.git",
        cmd = "Git",
        keys = {
            { "<leader>gh", "<Cmd>lua MiniGit.show_at_cursor()<cr>", silent = true, desc = "Git history" },
            { "<leader>gb", "<Cmd>vertical Git blame -- %<cr>",      silent = true, desc = "Git blame" },
            { "<leader>gd", "<Cmd>vertical Git diff -- %<cr>",       silent = true, desc = "Git diff" },
            { "<leader>gs", "<Cmd>vertical Git status<cr>",          silent = true, desc = "Git status" },
        },
        beforeAll = function()
            autocommand("User", {
                pattern = "MiniGitCommandSplit",
                callback = function(event)
                    buf_easy_close(event.buf)
                    if event.data.git_subcommand ~= "blame" then return end
                    -- Align blame output with source
                    local win_src = event.data.win_source
                    vim.wo.wrap = false
                    vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
                    vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })
                    -- Bind both windows so they scroll together
                    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
                end
            })
        end,
        after = function()
            require("mini.git").setup()
        end,
    },
    {
        "mini.hipatterns",
        event = "DeferredUIEnter",
        after = function()
            local minihipatterns = require("mini.hipatterns")
            minihipatterns.setup({
                highlighters = {
                    hex_color = minihipatterns.gen_highlighter.hex_color()
                }
            })
            command("TogglePatterns", minihipatterns.toggle)
        end
    },
    {
        "mini.icons",
        dep_of = { "blink.cmp", "mini.files", "mini.pick" },
        after = function() require("mini.icons").setup() end
    },
    {
        "mini.indentscope",
        event = "DeferredUIEnter",
        after = function() require("mini.indentscope").setup() end
    },
    {
        "mini.operators",
        keys = {
            { "g=", desc = "Evaluate operator", mode = { "n", "v", "x" } },
            { "gm", desc = "Multiply operator", mode = { "n", "v", "x" } },
            { "gr", desc = "Replace operator",  mode = { "n", "v", "x" } },
            { "gs", desc = "Sort operator",     mode = { "n", "v", "x" } },
            { "gx", desc = "Exchange operator", mode = { "n", "v", "x" } },
        },
        after = function() require("mini.operators").setup() end
    },
    {
        "mini.pairs",
        event = "InsertEnter",
        after = function() require("mini.pairs").setup() end
    },
    {
        "mini.pick",
        keys = {
            { "<leader> ",  "<Cmd>lua MiniPick.builtin.files({ tool = 'fd' })<cr>",            silent = true, desc = "Find files" },
            { "<leader>fb", "<Cmd>lua MiniExtra.pickers.buf_lines(nil, { tool = 'rg' })<cr>",  silent = true, desc = "Find in buffers" },
            { "<leader>fd", "<Cmd>lua MiniExtra.pickers.diagnostic(nil, { tool = 'rg' })<cr>", silent = true, desc = "Find diagnostics" },
            { "<leader>fg", "<Cmd>lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>",        silent = true, desc = "Find grep" },
            { "<leader>fh", "<Cmd>lua MiniExtra.pickers.git_hunks(nil, { tool = 'rg' })<cr>",  silent = true, desc = "Find hunks" },
            { "<leader>fv", "<Cmd>lua MiniPick.builtin.help({ tool = 'rg' })<cr>",             silent = true, desc = "Find vim help" },
        },
        after = function() require("mini.pick").setup() end,
    },
    {
        "mini.snippets",
        dep_of = "blink.cmp",
        after = function()
            local minisnippets = require("mini.snippets")
            minisnippets.setup({
                snippets = {
                    minisnippets.gen_loader.from_lang()
                },
                expand = {
                    match = function(snips)
                        return minisnippets.default_match(snips, { pattern_fuzzy = "%S+" })
                    end
                }
            })
        end
    },
    {
        "mini.splitjoin",
        keys = { "gS", desc = "Splitjoin operator", mode = { "n", "v", "x" } },
        after = function() require("mini.splitjoin").setup() end,
    },
    {
        "mini.statusline",
        event = "DeferredUIEnter",
        after = function() require("mini.statusline").setup() end
    },
    {
        "mini.surround",
        keys = { "s", desc = "Surround" },
        after = function() require("mini.surround").setup() end,
    },
    {
        "mini.trailspace",
        event = "BufEnter",
        after = function()
            local minitrailspace = require("mini.trailspace")
            minitrailspace.setup()
            autocommand("BufWritePre", {
                callback = function()
                    minitrailspace.trim_last_lines()
                end
            })
        end
    },
    {
        "nvim-dap",
        cmd = {
            "DapClearBreakpoints",
            "DapContinue",
            "DapDisconnect",
            "DapEval",
            "DapNew",
            "DapPause",
            "DapRestartFrame",
            "DapSetLogLevel",
            "DapShowLog",
            "DapStepInto",
            "DapStepOut",
            "DapStepOver",
            "DapTerminate",
            "DapToggleBreakpoint",
            "DapToggleRepl",
            "DapViewToggle",
        },
        keys = {
            { "<leader>db", "<Cmd>DapToggleBreakpoint<cr>", silent = true, desc = "Toggle breakpoint" },
            { "<leader>dc", "<Cmd>DapContinue<cr>",         silent = true, desc = "Run / Continue" },
            { "<leader>ds", "<Cmd>DapPause<cr>",            silent = true, desc = "Pause" },
            { "<leader>dt", "<Cmd>DapTerminate<cr>",        silent = true, desc = "Terminate" },
            { "<leader>di", "<Cmd>DapStepInto<cr>",         silent = true, desc = "Step into" },
            { "<leader>do", "<Cmd>DapStepOut<cr>",          silent = true, desc = "Step out" },
            { "<leader>dO", "<Cmd>DapStepOver<cr>",         silent = true, desc = "Step over" },
            { "<leader>dv", "<Cmd>DapViewToggle<cr>",       silent = true, desc = "Toggle view" },
        },
        after = function()
            local dap = require("dap")
            dap.adapters.delve = function(callback, config)
                if config.mode == "remote" and config.request == "attach" then
                    callback({
                        type = "server",
                        host = config.host or "127.0.0.1",
                        port = config.port or "38697"
                    })
                else
                    callback({
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = "dlv",
                            args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
                            env = {
                                CGO_CFLAGS = "-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"
                            },
                            detached = vim.fn.has("win32") == 0
                        }
                    })
                end
            end
            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Debug",
                    request = "launch",
                    program = "${file}"
                },
                {
                    type = "delve",
                    name = "Debug test",
                    request = "launch",
                    mode = "test",
                    program = "${file}"
                },
                {
                    type = "delve",
                    name = "Debug (go.mod)",
                    request = "launch",
                    program = "./${relativeFileDirname}"
                },
                {
                    type = "delve",
                    name = "Debug with args (go.mod)",
                    request = "launch",
                    program = "./${relativeFileDirname}",
                    args = function()
                        local input = vim.fn.input("Executable args: ", "", "file")
                        if input and input ~= "" then
                            return vim.split(input, "%s+")
                        end
                        return {}
                    end
                }
            }
        end
    },
    {
        "nvim-dap-view",
        dep_of = "dap",
        after = function()
            ---@type dapview.Config
            local dap_view_config = {}
            require("dap-view").setup(dap_view_config)
        end
    },
    {
        "nvim-lint",
        ft = "groovy",
        after = function()
            require("lint").linters_by_ft = {
                groovy = { "npm-groovy-lint" }
            }
            autocommand({ "BufEnter", "BufWritePost" }, {
                pattern = "*.groovy",
                callback = function()
                    require("lint").try_lint()
                end
            })
        end
    },
    {
        "onedarkpro.nvim",
        colorscheme = "onedark",
        after = function()
            require("onedarkpro").setup({
                options = {
                    transparency = true,
                    highlight_inactive_windows = true
                }
            })
        end
    },
    {
        "snacks.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("snacks").setup({
                rename = { enabled = true },
                words = { enabled = true },
            })
            autocommand("User", {
                pattern = "MiniFilesActionRename",
                callback = function(event)
                    require("snacks.rename").on_rename_file(event.data.from, event.data.to)
                end
            })
        end
    },
    {
        "typst-preview.nvim",
        ft = "typst",
        after = function()
            require("typst-preview").setup()
        end
    },
    {
        "zellij-nav",
        cmd = { "ZellijNavigateLeftTab", "ZellijNavigateDown", "ZellijNavigateUp", "ZellijNavigateRightTab" },
        keys = {
            { "<A-h>", "<Cmd>ZellijNavigateLeftTab<cr>",  silent = true, desc = "Navigate left" },
            { "<A-j>", "<Cmd>ZellijNavigateDown<cr>",     silent = true, desc = "Navigate down" },
            { "<A-k>", "<Cmd>ZellijNavigateUp<cr>",       silent = true, desc = "Navigate up" },
            { "<A-l>", "<Cmd>ZellijNavigateRightTab<cr>", silent = true, desc = "Navigate right" }
        },
        after = function()
            require("zellij-nav").setup()
        end
    }
})

vim.cmd("colorscheme onedark")
