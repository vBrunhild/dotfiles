if vim.env.PROF then
    require("snacks.profiler").startup({
        startup = {
            event = "VimEnter"
        }
    })
end

-- functions
--- @param mode string|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts? vim.keymap.set.Opts
local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent or true
    vim.keymap.set(mode, lhs, rhs, opts)
end

local autocommand = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

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
    vim.keymap.set("n", "q", ":close<cr>", { buffer = buf, silent = true })
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
command("ZellijPaneNew", "silent !zellij action new-pane", {})
command("ZellijTabNew", "silent !zellij action new-tab", {})

-- keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

map({ "n", "x", "v" }, "Y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "x", "v" }, "<C-a>", "ggVG", { desc = "Select all" })
map("n", "P", ":pu<cr>", { desc = "Paste in new line" })

map({ "n", "x" }, "<leader>ld", vim.lsp.buf.definition, { desc = "LSP goto definition" })
map({ "n", "x" }, "<leader>lr", vim.lsp.buf.rename, { desc = "LSP rename" })
map({ "n", "x" }, "<leader>lh", vim.lsp.buf.hover, { desc = "LSP hover" })
map({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map({ "n", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "LSP format" })

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
        local luarc_exists = vim.fn.glob(workspace .. "/.luarc.json") ~= "" or vim.fn.glob(workspace .. "/.luarc.jsonc") ~= ""
        if luarc_exists then return end

        local package_paths = vim.split(package.path, ";", { trimempty = true })
        local paths = { vim.env.VIMRUNTIME, vim.api.nvim_get_runtime_file('*/myNeovimPackages/start', false)[1] }

        local settings = {
            runtime = {
                version = "LuaJIT",
                path = vim.list_extend({ "lua/?.lua", "lua/?/init.lua" }, package_paths)
            },
            workspace = {
                checkThirdParty = false,
                library = paths
            }
        }

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, settings)
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

require("nvim-treesitter.configs").setup({
    ensure_installed = {},
    sync_install = false,
    auto_install = false,
    ignore_install = { "all" },
    modules = {},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true
    }
})

---@type lze.PluginSpec[]
require("lze").load({
    {
        "blink.cmp",
        event = "DeferredUIEnter",
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
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        after = function()
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
                    jsonc = { "dprint" },
                    nix = { "alejandra" },
                    rust = { "rustfmt" }
                },
                default_format_opts = {
                    lsp_format = "fallback"
                }
            })
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
                    { mode = "n", keys = "<Leader>" },
                    { mode = "x", keys = "<Leader>" },
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
        after = function() require("mini.diff").setup() end
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
            { "<leader>e", ":lua if not MiniFiles.close() then MiniFiles.open() end<cr>", silent = true, desc = "File explorer" }
        }
    },
    {
        "mini.git",
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
        cmd = "Git",
        keys = {
            { "<leader>gh", ":lua MiniGit.show_at_cursor()<cr>", silent = true, desc = "Git history" },
            { "<leader>gb", ":vertical Git blame -- %<cr>",      silent = true, desc = "Git blame" },
            { "<leader>gd", ":vertical Git diff -- %<cr>",       silent = true, desc = "Git diff" },
            { "<leader>gs", ":vertical Git status<cr>",          silent = true, desc = "Git status" },
        }
    },
    {
        "mini.hipatterns",
        event = "DeferredUIEnter",
        after = function() require("mini.hipatterns").setup() end
    },
    {
        "mini.icons",
        after = function() require("mini.icons").setup() end
    },
    {
        "mini.indentscope",
        event = "DeferredUIEnter",
        after = function() require("mini.indentscope").setup() end
    },
    {
        "mini.operators",
        after = function() require("mini.operators").setup() end
    },
    {
        "mini.pairs",
        after = function() require("mini.pairs").setup() end
    },
    {
        "mini.pick",
        keys = {
            { "<leader> ",  ":lua MiniPick.builtin.files({ tool = 'fd' })<cr>",            silent = true, desc = "Find files" },
            { "<leader>fg", ":lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>",        silent = true, desc = "Find grep" },
            { "<leader>fb", ":lua MiniExtra.pickers.buf_lines(nil, { tool = 'rg' })<cr>",  silent = true, desc = "Find in buffers" },
            { "<leader>fh", ":lua MiniExtra.pickers.git_hunks(nil, { tool = 'rg' })<cr>",  silent = true, desc = "Find hunks" },
            { "<leader>fd", ":lua MiniExtra.pickers.diagnostic(nil, { tool = 'rg' })<cr>", silent = true, desc = "Find diagnostics" },
            { "<leader>fv", ":lua MiniPick.builtin.help({ tool = 'rg' })<cr>",             silent = true, desc = "Find vim help" },
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
        keys = "gS",
        after = function() require("mini.splitjoin").setup() end,
    },
    {
        "mini.statusline",
        after = function() require("mini.statusline").setup() end
    },
    {
        "mini.surround",
        keys = "s",
        after = function() require("mini.surround").setup() end,
    },
    {
        "mini.trailspace",
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
        "nvim-colorizer",
        cmd = { "ColorizerToggle" },
        keys = {
            { "<leader>c", ":ColorizerToggle<cr>", silent = true, desc = "Colorizer toggle" }
        }
    },
    {
        "dap",
        config = function()
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
        "dap-view",
    },
    {
        "lint",
        event = "DeferredUIEnter",
        config = function()
            require("lint").linters_by_ft = {
                groovy = { "npm-groovy-lint" }
            }
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
        lazy = false,
        priority = 999,
        after = function()
            require("snacks").setup({
                bigfile = { enabled = true },
                quickfile = { enabled = true },
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
        "typst-preview",
        ft = "typst"
    },
    {
        "zellij-nav",
        cmd = { "ZellijNavigateLeftTab", "ZellijNavigateDown", "ZellijNavigateUp", "ZellijNavigateRightTab" },
        keys = {
            { "<A-h>", ":ZellijNavigateLeftTab<cr>",  silent = true, desc = "Navigate left" },
            { "<A-j>", ":ZellijNavigateDown<cr>",     silent = true, desc = "Navigate down" },
            { "<A-k>", ":ZellijNavigateUp<cr>",       silent = true, desc = "Navigate up" },
            { "<A-l>", ":ZellijNavigateRightTab<cr>", silent = true, desc = "Navigate right" }
        },
        after = function()
            require("zellij-nav").setup()
        end
    }
})

vim.cmd("colorscheme onedark")
