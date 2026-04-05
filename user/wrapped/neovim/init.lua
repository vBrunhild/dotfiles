-- functions

---@class MapConfig : vim.keymap.set.Opts
---@field [1] string
---@field [2] string|function
---@field mode? string|string[]

---@param configs MapConfig[]
local map = function(configs)
    for _, config in ipairs(configs) do
        local lhs = config[1]
        config[1] = nil
        local rhs = config[2]
        config[2] = nil
        local mode = config.mode or "n"
        config.mode = nil
        vim.keymap.set(mode, lhs, rhs, config)
    end
end

---@class CommandOpts : vim.api.keyset.user_command
---@field [1] string
---@field [2] string|fun(args: vim.api.keyset.create_user_command.command_args)

---@param optsTable CommandOpts[]
local command = function(optsTable)
    for _, opts in ipairs(optsTable) do
        local name = opts[1]
        opts[1] = nil
        local command = opts[2]
        opts[2] = nil
        vim.api.nvim_create_user_command(name, command, opts)
    end
end

local autocommand = vim.api.nvim_create_autocmd

-- configs
local border = "rounded"

vim.g.clipboard = "osc52"
vim.o.backup = false
vim.o.breakindent = true
vim.o.completeopt = "menuone,noselect,fuzzy,nosort"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.expandtab = true
vim.o.fillchars = "eob: "
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "indent"
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.infercase = true
vim.o.jumpoptions = "stack,view"
vim.o.linebreak = true
vim.o.list = true
vim.o.mouse = ""
vim.o.number = true
vim.o.pumblend = 50
vim.o.pumborder = border
vim.o.relativenumber = true
vim.o.ruler = false
vim.o.scrolloff = 10
vim.o.shiftwidth = 4
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.virtualedit = "block"
vim.o.wildmenu = true
vim.o.wildmode = "noselect,full"
vim.o.wildoptions = "pum,fuzzy"
vim.o.winblend = 50
vim.o.winborder = border
vim.o.wrap = false
vim.o.writebackup = false
vim.opt.formatoptions:append { o = false, r = false }
vim.opt.listchars:append { tab = "> ", extends = "…", precedes = "…", nbsp = "␣", trail = "·" }
vim.opt.shortmess:append("I")

vim.diagnostic.config({
    float = { source = true },
    severity_sort = true,
    signs = true,
    underline = false,
    update_in_insert = false,
    virtual_lines = false,
    virtual_text = true,
})

-- autocommands
local buf_easy_close = function(buf)
    vim.bo[buf].buflisted = false
    map({ { "q", "<Cmd>close<cr>", buffer = buf } })
end

autocommand("FileType", {
    desc = "Easy close",
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
    desc = "Highlight on yank",
    callback = function() vim.hl.on_yank() end
})

autocommand("FileType", {
    desc = "Set indent for specific files",
    pattern = {
        "css",
        "html",
        "javascript",
        "json",
        "nix",
        "opentofu",
        "opentofu-vars",
        "nu",
        "typescript",
        "typst",
        "terraform",
        "hcl",
    },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
    end
})

autocommand('FileType', {
    callback = function(args) pcall(vim.treesitter.start, args.buf) end
})

autocommand("VimLeave", {
    command = "silent !zellij action switch-mode normal"
})

-- commands
command({
    { "ZellijPaneNew", function() vim.cmd("silent !zellij action new-pane") end },
    { "ZellijTabNew",  function() vim.cmd("silent !zellij action new-tab --cwd " .. vim.fn.getcwd()) end },
})

-- keymaps
vim.g.mapleader = " "

---@param direction '"h"'|'"j"'|'"k"'|'"l"'
---@param move_tab boolean?
local nav = function(direction, move_tab)
    local action = "move-focus"
    if move_tab then
        action = "move-focus-or-tab"
    end
    local zellij_direction
    if direction == "h" then
        zellij_direction = "left"
    elseif direction == "j" then
        zellij_direction = "down"
    elseif direction == "k" then
        zellij_direction = "up"
    elseif direction == "l" then
        zellij_direction = "right"
    end
    local current_window = vim.fn.winnr()
    vim.cmd("wincmd " .. direction)
    local new_window = vim.fn.winnr()
    if current_window == new_window then
        vim.fn.system("zellij action " .. action .. " " .. zellij_direction)
    end
end

---@param file string
local dragon = function(file)
    vim.fn.jobstart({ "dragon-drop", "--and-exit", file })
end

map({
    -- general stuff
    { "<C-a>",      "ggVG",                                      mode = { "n", "x" },                 desc = "Select all" },
    { "<C-j>",      "<C-d>zz",                                   mode = { "n", "x" },                 desc = "Page down" },
    { "<C-k>",      "<C-u>zz",                                   mode = { "n", "x" },                 desc = "Page up" },
    { "<leader>k",  vim.diagnostic.open_float,                   desc = "Show diagnostic" },
    { "<leader>w",  "<Cmd>setlocal wrap!<cr>",                   desc = "Toggle wrap" },
    { "P",          "<Cmd>pu<cr>",                               desc = "Paste in new line" },
    { "g/",         "<Esc>/\\%V",                                mode = "x",                          desc = "Search inside visual selection" },
    { "gy",         '"+y',                                       mode = { "n", "x" },                 desc = "Yank to clipboard" },
    -- lsp stuff
    { "<leader>la", vim.lsp.buf.code_action,                     mode = { "n", "x" },                 desc = "LSP code action" },
    { "<leader>ld", vim.lsp.buf.definition,                      mode = { "n", "x" },                 desc = "LSP goto definition" },
    { "<leader>lr", vim.lsp.buf.rename,                          mode = { "n", "x" },                 desc = "LSP rename" },
    { "<leader>lt", vim.lsp.buf.type_definition,                 mode = { "n", "x" },                 desc = "LSP goto type definition" },
    { "<leader>lw", vim.lsp.buf.workspace_diagnostics,           mode = { "n", "x" },                 desc = "LSP workspace diagnostics" },
    -- zellij
    { "<A-h>",      function() nav("h", true) end,               desc = "Navigate left",              silent = true },
    { "<A-j>",      function() nav("j") end,                     desc = "Navigate down",              silent = true },
    { "<A-k>",      function() nav("k") end,                     desc = "Navigate up",                silent = true },
    { "<A-l>",      function() nav("l", true) end,               desc = "Navigate right",             silent = true },
    { "<leader>tp", "<Cmd>ZellijPaneNew<cr>",                    desc = "Open new pane",              silent = true },
    { "<leader>tt", "<Cmd>ZellijTabNew<cr>",                     desc = "Open new tab",               silent = true },
    -- tools
    { "<leader>d",  function() dragon(vim.fn.expand("%:p")) end, desc = "Open current file on dragon" },
})

-- lsp
vim.lsp.config("harper_ls", {
    filetypes = {
        "gitcommit",
        "markdown",
        "typst",
    }
})

vim.lsp.config("lua_ls", {
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
                    "${3rd}/busted/library",
                    "${3rd}/luv/library",
                    "lua/?.lua",
                    "lua/?/init.lua",
                }
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
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

vim.lsp.enable({
    "clangd",
    "cssls",
    "docker_language_server",
    "dprint",
    "golangci_lint_ls",
    "gopls",
    "groovyls",
    "harper_ls",
    "html",
    "jsonls",
    "just",
    "lua_ls",
    "markdown_oxide",
    "nil_ls",
    "nixd",
    "nushell",
    "phpactor",
    "psalm",
    "pyrefly",
    "ruff",
    "rust_analyzer",
    "taplo",
    "tinymist",
    "tofu_ls",
    "ts_ls",
})

vim.lsp.inlay_hint.enable(true)

-- plugins
if vim.env.NVIM_MINIMAL then
    return
end

vim.opt.rtp:append("/home/brunhild/repositories/simple-start-screen")
require("sss").setup()

require("onedarkpro").setup({
    options = {
        transparency = true,
        highlight_inactive_windows = true,
    },
    highlights = {
        -- Pmenu = { bg = "bg", fg = "fg" },
        -- PmenuBorder = { bg = "bg", fg = "fg" },
    }
})

vim.cmd("colorscheme onedark")

require("lze").load({
    {
        "conform",
        event = { "BufEnter" },
        keys = {
            {
                "<leader>lf",
                function() require("conform").format({ async = true }) end,
                mode = { "n", "x", "v" },
                desc = "LSP format"
            }
        },
        beforeAll = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
        after = function()
            ---@type conform.setupOpts
            local conform_config = {
                formatters_by_ft = {
                    cpp = { "clang-format" },
                    groovy = { "npm-groovy-lint" },
                    javascript = { "dprint", "prettierd" },
                    json = { "dprint" },
                    jsonc = { "dprint" },
                    nix = { "alejandra", lsp_format = "never" },
                    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                    rust = { "rustfmt" },
                    typescript = { "dprint", "prettierd" },
                },
                default_format_opts = {
                    lsp_format = "fallback",
                    stop_after_first = true,
                }
            }
            require("conform").setup(conform_config)
        end
    },
    {
        "mini.align",
        keys = {
            { "ga", desc = "Align",              mode = { "n", "x" } },
            { "gA", desc = "Align with preview", mode = { "n", "x" } }
        },
        after = function()
            require("mini.align").setup()
        end
    },
    {
        "mini.bufremove",
        event = "DeferredUIEnter",
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
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                    { mode = "n", keys = "<leader>f",  desc = "+Picker" },
                    { mode = "n", keys = "<leader>fl", desc = "+Lsp Pickers" },
                    { mode = "n", keys = "<leader>g",  desc = "+Git" },
                    { mode = "n", keys = "<leader>l",  desc = "+LSP" },
                    { mode = "n", keys = "<leader>t",  desc = "+Terminal" },
                },
                window = {
                    delay = 1000,
                    config = {
                        width = "auto"
                    }
                }
            })
        end
    },
    {
        "mini.cmdline",
        event = "DeferredUIEnter",
        after = function()
            require("mini.cmdline").setup({
                autopeek = {
                    enabled = true,
                    n_context = 5,
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
        "mini.completion",
        event = "DeferredUIEnter",
        after = function()
            require("mini.completion").setup()
        end
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
        lazy = vim.fn.argc(-1) == 0,
        keys = {
            {
                "<leader>e",
                "<Cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>",
                silent = true,
                desc = "File explorer"
            },
            {
                "<leader>E",
                "<Cmd>lua if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end<cr>",
                silent = true,
                desc = "File explorer on current directory"
            },
        },
        after = function()
            require("mini.files").setup({
                windows = {
                    max_number = 3,
                    width_focus = 35,
                    width_nofocus = 35,
                    widthpreview = 35
                }
            })
        end,
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
        end
    },
    {
        "mini.icons",
        dep_of = {
            "mini.completion",
            "mini.files",
            "mini.pick",
            "mini.statusline",
            "mini.tabline",
        },
        after = function()
            require("mini.icons").setup()
            MiniIcons.tweak_lsp_kind()
        end,
    },
    {
        "mini.indentscope",
        event = "DeferredUIEnter",
        after = function() require("mini.indentscope").setup() end
    },
    {
        "mini.keymap",
        event = "DeferredUIEnter",
        after = function()
            local mini_keymap = require("mini.keymap")
            local map_multistep = mini_keymap.map_multistep

            local tab_steps = { 'minisnippets_next', 'minisnippets_expand', 'pmenu_next' }
            map_multistep('i', '<Tab>', tab_steps)

            local shifttab_steps = { 'minisnippets_prev', 'pmenu_prev' }
            map_multistep('i', '<S-Tab>', shifttab_steps)

            local enter_steps = { 'pmenu_accept' }
            map_multistep('i', '<CR>', enter_steps)
        end
    },
    {
        "mini.notify",
        event = "DeferredUIEnter",
        after = function() require("mini.notify").setup() end
    },
    {
        "mini.operators",
        event = "DeferredUIEnter",
        after = function() require("mini.operators").setup() end
    },
    {
        "mini.pick",
        keys = {
            { "<leader> ",   "<Cmd>lua MiniPick.builtin.files({ tool = 'rg' })<cr>",               desc = "Find files" },
            { "<leader>b",   "<Cmd>lua MiniPick.builtin.buffers({ tool = 'rg' })<cr>",             desc = "Find buffers" },
            { "<leader>fb",  "<Cmd>lua MiniExtra.pickers.buf_lines(nil, { tool = 'rg' })<cr>",     desc = "Find in buffers" },
            { "<leader>fd",  "<Cmd>lua MiniExtra.pickers.diagnostic(nil, { tool = 'rg' })<cr>",    desc = "Find diagnostics" },
            { "<leader>fg",  "<Cmd>lua MiniPick.builtin.grep_live({ tool = 'rg' })<cr>",           desc = "Find grep" },
            { "<leader>fh",  "<Cmd>lua MiniExtra.pickers.git_hunks(nil, { tool = 'rg' })<cr>",     desc = "Find hunks" },
            { "<leader>fld", "<Cmd>lua MiniExtra.pickers.lsp({ scope = 'document_symbol' })<cr>",  desc = "Find LSP document symbols" },
            { "<leader>flr", "<Cmd>lua MiniExtra.pickers.lsp({ scope = 'references' })<cr>",       desc = "Find LSP references" },
            { "<leader>flw", "<Cmd>lua MiniExtra.pickers.lsp({ scope = 'workspace_symbol' })<cr>", desc = "Find LSP workspace symbols" },
            { "<leader>fm",  "<Cmd>lua MiniExtra.pickers.marks(nil, { tool = 'rg' })<cr>",         desc = "Find markers" },
            { "<leader>fv",  "<Cmd>lua MiniPick.builtin.help({ tool = 'rg' })<cr>",                desc = "Find vim help" },
        },
        after = function() require("mini.pick").setup() end,
    },
    {
        "mini.snippets",
        dep_of = "mini.completion",
        after = function()
            local minisnippets = require("mini.snippets")
            minisnippets.setup({
                snippets = {
                    minisnippets.gen_loader.from_lang(),
                },
                expand = {
                    match = function(snippets)
                        return minisnippets.default_match(
                            snippets,
                            { pattern_fuzzy = "%S+" }
                        )
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
        after = function()
            local statusline = require("mini.statusline")
            local content = function()
                local diagnostics_signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = "󱧡 " }
                local mode, mode_hl     = statusline.section_mode({ trunc_width = 120 })
                local diff              = statusline.section_diff({ trunc_width = 75 })
                local diagnostics       = statusline.section_diagnostics({ trunc_width = 75, signs = diagnostics_signs })
                local filename          = statusline.section_filename({ trunc_width = 140 })
                local search            = statusline.section_searchcount({ trunc_width = 75 })
                local location          = statusline.section_location({ trunc_width = 75 })
                return statusline.combine_groups({
                    { hl = mode_hl,                 strings = { mode } },
                    { hl = "MiniStatuslineDevinfo", strings = { diff } },
                    "%<", -- Mark general truncate point
                    { hl = "MiniStatuslineFilename", strings = { filename } },
                    "%=", -- End left alignment
                    { hl = "MiniStatuslineDevinfo",  strings = { diagnostics } },
                    { hl = mode_hl,                  strings = { search, location } },
                })
            end
            statusline.setup({
                content = { active = content }
            })
        end
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
        "typst-preview.nvim",
        ft = "typst",
        after = function()
            require("typst-preview").setup()
        end
    }
})
