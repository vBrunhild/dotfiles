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
vim.o.shell = "bash"
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
vim.opt.shortmess:append("I")

vim.opt.listchars:append {
    tab = "> ",
    extends = "…",
    precedes = "…",
    nbsp = "␣",
    trail = "·"
}

vim.opt.diffopt:append {
    "algorithm:patience",
    "filler",
    "indent-heuristic",
    "iwhite",
    "vertical",
}

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

autocommand({ "TextYankPost", "TextPutPost" }, {
    desc = "Highlight on yank",
    callback = function() vim.hl.hl_op() end
})

autocommand("FileType", {
    desc = "Set indent for specific files",
    pattern = {
        "css",
        "hcl",
        "html",
        "javascript",
        "json",
        "nix",
        "nu",
        "opentofu",
        "opentofu-vars",
        "terraform",
        "tf",
        "typescript",
        "typst",
    },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
    end
})

autocommand('FileType', {
    callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if not ok then
            return
        end
        vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
    end
})

autocommand("VimLeave", {
    command = "silent !zellij action switch-mode normal"
})

autocommand("VimResized", {
    desc = "Automatically resize splits when the window resizes",
    pattern = "*",
    command = "tabdo wincmd =",
})

-- commands
command({
    {
        "Diff",
        function(opts)
            local files = opts.fargs
            if #files ~= 2 then
                vim.notify("Usage: :Diff file1 file2", vim.log.levels.ERROR)
                return
            end

            local function open_file(path)
                local abs = vim.fn.fnamemodify(path, ":p")
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p") == abs then
                        vim.cmd("buffer " .. buf)
                        return
                    end
                end
                vim.cmd("edit " .. vim.fn.fnameescape(path))
            end

            open_file(files[1])
            vim.cmd("diffthis")
            vim.cmd("vsplit")

            open_file(files[2])
            vim.cmd("diffthis")
        end,
        nargs = "+",
        complete = "file",
        desc = "Diff two files side by side"
    },
    {
        "PyreflyCheck", function()
        local chunks = {}

        vim.fn.setqflist(
            {},
            "r",
            { title = "Pyrefly Check: Running" }
        )

        local cmd = {
            "pyrefly", "check",
            "--output-format=json",
            "--summary=none",
            "--progress-bar=no",
        }

        vim.fn.jobstart(cmd, {
            stdout_buffered = false,
            on_stdout = function(_, data)
                if data then
                    for _, chunk in ipairs(data) do
                        if chunk ~= "" then
                            table.insert(chunks, chunk)
                        end
                    end
                end
            end,
            on_exit = function(_, _)
                local raw_json = table.concat(chunks, "")

                if raw_json == "" or raw_json == "[]" then
                    vim.fn.setqflist({}, "r", { title = "Pyrefly Check: Clean" })
                    return
                end

                local ok, decoded = pcall(vim.json.decode, raw_json)
                if not ok then
                    vim.notify("Pyrefly Check: Failed to parse JSON output.")
                    return
                end

                ---@diagnostic disable-next-line: undefined-field
                local errors = decoded.errors
                local qf_items = {}

                for _, err in ipairs(errors) do
                    table.insert(qf_items, {
                        filename = err.path,
                        lnum = err.line,
                        col = err.column,
                        end_lnum = err.stop_line,
                        end_col = err.stop_column,
                        text = ("[%s] %s").format(err.name, err.concise_description),
                        type = (err.severity == "warning") and "W" or "E",
                    })
                end

                vim.fn.setqflist({}, "r", {
                    title = "Pyrefly Check",
                    items = qf_items,
                })

                if #qf_items > 0 then
                    vim.cmd("copen")
                else
                    vim.notify("Pyrefly Check: No errors found")
                end
            end
        })
    end
    },
    -- zellij
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
    { "<leader>w",  "<Cmd>setlocal wrap!<cr>",                   desc = "Toggle wrap" },
    { "P",          "<Cmd>pu<cr>",                               desc = "Paste in new line" },
    { "g/",         "<Esc>/\\%V",                                mode = "x",                          desc = "Search inside visual selection" },
    { "gy",         '"+y',                                       mode = { "n", "x" },                 desc = "Yank to clipboard" },
    { "H",          "0",                                         mode = { "n", "x" },                 desc = "Jump to start of line" },
    { "L",          "$",                                         mode = { "n", "x" },                 desc = "Jump to end of line" },
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
vim.lsp.config["*"] = {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        },
    },
    root_markers = { ".git" },
}

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
                    vim.api.nvim_get_runtime_file("*/myNeovimPackages/start", false)[1],
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

vim.lsp.config("path_server", {
    cmd = { 'path-server' },
})

vim.lsp.config("phpantom_lsp", {
    cmd = { 'phpantom_lsp' },
    filetypes = { 'php' },
    root_markers = { '.phpantom.toml', '.git', 'composer.json' },
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
    "path_server",
    "phpactor",
    "phpantom_lsp",
    "pyrefly",
    "ruff",
    "rust_analyzer",
    "taplo",
    "tinymist",
    "tofu_ls",
    "ts_ls",
})

vim.lsp.inlay_hint.enable(true)
vim.lsp.codelens.enable(true)

-- treesitter
vim.treesitter.language.register('hcl', 'atlas-config')
vim.treesitter.language.register('hcl', 'atlas-plan')
vim.treesitter.language.register('hcl', 'atlas-rule')
vim.treesitter.language.register('hcl', 'atlas-rule')
vim.treesitter.language.register('hcl', 'atlas-schema-clickhouse')
vim.treesitter.language.register('hcl', 'atlas-schema-mssql')
vim.treesitter.language.register('hcl', 'atlas-schema-mysql')
vim.treesitter.language.register('hcl', 'atlas-schema-postgresql')
vim.treesitter.language.register('hcl', 'atlas-schema-redshift')
vim.treesitter.language.register('hcl', 'atlas-schema-sqlite')
vim.treesitter.language.register('hcl', 'atlas-test')
vim.treesitter.language.register('hcl', 'tf')

-- plugins
if vim.env.NVIM_MINIMAL then
    return
end

local color = require("onedarkpro.helpers")
local colors = color.get_colors("onedark")

require("onedarkpro").setup({
    options = {
        cursorline = true,
        highlight_inactive_windows = true,
        lualine_transparency = true,
        transparency = true,
    },
    colors = {
        -- default
        cursorline  = color.lighten(colors.bg, 20),

        -- custom
        bg_edge     = color.darken(colors.bg, 5),
        bg_edge2    = color.darken(colors.bg, 10),
        bg_mid      = color.lighten(colors.bg, 5),
        bg_mid2     = color.lighten(colors.bg, 10),

        fg_edge     = color.darken(colors.fg, 5),
        fg_edge2    = color.darken(colors.fg, 10),
        fg_mid      = color.lighten(colors.fg, 5),
        fg_mid2     = color.lighten(colors.fg, 10),

        accent      = colors.purple,

        dark_cyan   = color.darken(colors.cyan, 10),
        dark_green  = color.darken(colors.green, 10),
        dark_red    = color.darken(colors.red, 10),
        dark_yellow = color.darken(colors.yellow, 10),
    },
    highlights = {
        -- default
        ColorColumn                      = { fg = nil, bg = "${bg_mid2}" },
        ComplMatchIns                    = { fg = nil, bg = nil },
        Conceal                          = { fg = "${blue}", bg = nil },
        CurSearch                        = { fg = "${bg}", bg = "${yellow}" },
        Cursor                           = { fg = "${bg}", bg = "${fg}" },
        CursorColumn                     = { fg = nil, bg = "${bg_mid}" },
        CursorIM                         = { link = "Cursor" },
        CursorLine                       = { fg = nil, bg = "${bg_mid}" },
        CursorLineFold                   = { fg = "${bg_mid2}", bg = nil },
        CursorLineNr                     = { fg = "${accent}", bg = nil, bold = true },
        CursorLineSign                   = { fg = "${bg_mid2}", bg = nil },
        DiagnosticDeprecated             = { fg = nil, bg = nil, sp = "${red}", strikethrough = true },
        DiagnosticError                  = { fg = "${red}", bg = nil },
        DiagnosticFloatingError          = { fg = "${red}", bg = nil },
        DiagnosticFloatingHint           = { fg = "${cyan}", bg = nil },
        DiagnosticFloatingInfo           = { fg = "${blue}", bg = nil },
        DiagnosticFloatingOk             = { fg = "${green}", bg = nil },
        DiagnosticFloatingWarn           = { fg = "${yellow}", bg = nil },
        DiagnosticHint                   = { fg = "${cyan}", bg = nil },
        DiagnosticInfo                   = { fg = "${blue}", bg = nil },
        DiagnosticOk                     = { fg = "${green}", bg = nil },
        DiagnosticSignError              = { link = "DiagnosticError" },
        DiagnosticSignHint               = { link = "DiagnosticHint" },
        DiagnosticSignInfo               = { link = "DiagnosticInfo" },
        DiagnosticSignOk                 = { link = "DiagnosticOk" },
        DiagnosticSignWarn               = { link = "DiagnosticWarn" },
        DiagnosticUnderlineError         = { fg = nil, bg = nil, sp = "${red}", underline = true },
        DiagnosticUnderlineHint          = { fg = nil, bg = nil, sp = "${cyan}", underline = true },
        DiagnosticUnderlineInfo          = { fg = nil, bg = nil, sp = "${blue}", underline = true },
        DiagnosticUnderlineOk            = { fg = nil, bg = nil, sp = "${green}", underline = true },
        DiagnosticUnderlineWarn          = { fg = nil, bg = nil, sp = "${yellow}", underline = true },
        DiagnosticUnnecessary            = { link = "Comment" },
        DiagnosticVirtualTextError       = { link = "DiagnosticError" },
        DiagnosticVirtualTextHint        = { link = "DiagnosticHint" },
        DiagnosticVirtualTextInfo        = { link = "DiagnosticInfo" },
        DiagnosticVirtualTextOk          = { link = "DiagnosticOk" },
        DiagnosticVirtualTextWarn        = { link = "DiagnosticWarn" },
        DiagnosticWarn                   = { fg = "${yellow}", bg = nil },
        DiffTextAdd                      = { link = "DiffAdd" },
        Directory                        = { fg = "${blue}", bg = nil },
        EndOfBuffer                      = { fg = "${bg_mid2}", bg = nil },
        ErrorMsg                         = { fg = "${red}", bg = nil },
        FloatBorder                      = { fg = "${fg}", bg = nil },
        FloatTitle                       = { fg = "${green}", bg = nil, bold = true },
        FoldColumn                       = { fg = "${bg_mid2}", bg = nil },
        Folded                           = { fg = "${fg_mid2}", bg = "${bg_edge}" },
        IncSearch                        = { fg = "${bg}", bg = "${yellow}" },
        LineNr                           = { fg = "${bg_mid2}", bg = nil },
        LineNrAbove                      = { link = "LineNr" },
        LineNrBelow                      = { link = "LineNr" },
        MatchParen                       = { fg = nil, bg = "${bg_mid2}", bold = true },
        ModeMsg                          = { fg = "${green}", bg = nil },
        MoreMsg                          = { fg = "${blue}", bg = nil },
        MsgArea                          = { link = "Normal" },
        MsgSeparator                     = { fg = "${accent}", bg = "${bg_mid}" },
        NonText                          = { fg = "${bg_mid2}", bg = nil },
        Normal                           = { fg = "${fg}", bg = nil },
        NormalFloat                      = { fg = "${fg}", bg = nil },
        NormalNC                         = { link = "Normal" },
        OkMsg                            = { fg = "${green}", bg = nil },
        Pmenu                            = { bg = nil, fg = "${fg}" },
        PmenuBorder                      = { link = "Pmenu" },
        PmenuExtra                       = { link = "Pmenu" },
        PmenuExtraSel                    = { link = "PmenuSel" },
        PmenuKind                        = { link = "Pmenu" },
        PmenuKindSel                     = { link = "PmenuSel" },
        PmenuMatch                       = { fg = nil, bg = nil, bold = true },
        PmenuMatchSel                    = { fg = nil, bg = nil, bold = true, blend = 0, reverse = true },
        PmenuSbar                        = { link = "Pmenu" },
        PmenuSel                         = { fg = nil, bg = nil, blend = 0, reverse = true },
        PmenuThumb                       = { fg = nil, bg = "${purple}" },
        Question                         = { fg = "${blue}", bg = nil },
        QuickFixLine                     = { fg = nil, bg = nil, bold = true },
        Search                           = { fg = nil, bg = "${bg_mid2}" },
        SignColumn                       = { fg = "${bg_mid2}", bg = nil },
        SpecialKey                       = { fg = "${accent}", bg = nil },
        SpellBad                         = { fg = nil, bg = nil, sp = "${red}", undercurl = true },
        SpellCap                         = { fg = nil, bg = nil, sp = "${cyan}", undercurl = true },
        SpellLocal                       = { fg = nil, bg = nil, sp = "${yellow}", undercurl = true },
        SpellRare                        = { fg = nil, bg = nil, sp = "${blue}", undercurl = true },
        StatusLine                       = { fg = "${fg}", bg = nil },
        StatusLineNC                     = { link = "StatusLine" },
        StderrMsg                        = { link = "ErrorMsg" },
        StdoutMsg                        = { link = "MsgArea" },
        Substitute                       = { fg = "${bg}", bg = "${fg}" },
        TabLine                          = { fg = "${fg_mid}", bg = "${bg_edge}" },
        TabLineFill                      = { link = "TabLine" },
        TabLineSel                       = { fg = "${accent}", bg = "${bg_edge}" },
        TermCursor                       = { fg = nil, bg = nil, reverse = true },
        TermCursorNC                     = { fg = nil, bg = nil, reverse = true },
        Title                            = { fg = "${green}", bg = nil },
        VertSplit                        = { fg = "${accent}", bg = nil },
        Visual                           = { fg = nil, bg = "${bg_mid2}" },
        VisualNOS                        = { fg = nil, bg = "${bg_mid}" },
        WarningMsg                       = { fg = "${yellow}", bg = nil },
        Whitespace                       = { fg = "${bg_mid2}", bg = nil },
        WildMenu                         = { link = "PmenuSel" },
        WinBar                           = { link = "StatusLine" },
        WinBarNC                         = { link = "StatusLineNC" },
        WinSeparator                     = { fg = "${accent}", bg = "${accent}" },
        lCursor                          = { fg = "${bg}", bg = "${fg}" },
        --plugins
        MiniClueBorder                   = { link = "FloatBorder" },
        MiniClueDescGroup                = { link = "DiagnosticFloatingWarn" },
        MiniClueDescSingle               = { link = "NormalFloat" },
        MiniClueNextKey                  = { link = "DiagnosticFloatingHint" },
        MiniClueNextKeyWithPostkeys      = { link = "DiagnosticFloatingError" },
        MiniClueSeparator                = { link = "DiagnosticFloatingInfo" },
        MiniClueTitle                    = { link = "FloatTitle" },
        MiniCmdlinePeekBorder            = { link = "FloatBorder" },
        MiniCmdlinePeekLineNr            = { link = "DiagnosticSignWarn" },
        MiniCmdlinePeekNormal            = { link = "NormalFloat" },
        MiniCmdlinePeekSep               = { link = "SignColumn" },
        MiniCmdlinePeekSign              = { link = "DiagnosticSignHint" },
        MiniCmdlinePeekTitle             = { link = "FloatTitle" },
        MiniCompletionActiveParameter    = { link = "LspSignatureActiveParameter" },
        MiniCompletionDeprecated         = { link = "DiagnosticDeprecated" },
        MiniCompletionInfoBorderOutdated = { link = "DiagnosticFloatingWarn" },
        MiniDepsChangeAdded              = { link = "diffAdded" },
        MiniDepsChangeRemoved            = { link = "diffRemoved" },
        MiniDepsHint                     = { link = "DiagnosticHint" },
        MiniDepsInfo                     = { link = "DiagnosticInfo" },
        MiniDepsMsgBreaking              = { link = "DiagnosticWarn" },
        MiniDepsPlaceholder              = { link = "Comment" },
        MiniDepsTitle                    = { link = "Title" },
        MiniDepsTitleError               = { link = "DiffDelete" },
        MiniDepsTitleSame                = { link = "DiffText" },
        MiniDepsTitleUpdate              = { link = "DiffAdd" },
        MiniDiffSignAdd                  = { link = "diffAdded" },
        MiniDiffSignChange               = { link = "diffChanged" },
        MiniDiffSignDelete               = { link = "diffRemoved" },
        MiniDiffOverAdd                  = { link = "DiffAdd" },
        MiniDiffOverChange               = { link = "DiffText" },
        MiniDiffOverChangeBuf            = { link = "MiniDiffOverChange" },
        MiniDiffOverContext              = { link = "DiffChange" },
        MiniDiffOverContextBuf           = {},
        MiniDiffOverDelete               = { link = "DiffDelete" },
        MiniFilesBorder                  = { link = "FloatBorder" },
        MiniFilesBorderModified          = { link = "DiagnosticFloatingWarn" },
        MiniFilesCursorLine              = { link = "CursorLine" },
        MiniFilesDirectory               = { link = "Directory" },
        MiniFilesFile                    = { fg = "${fg}", bg = nil },
        MiniFilesNormal                  = { link = "NormalFloat" },
        MiniFilesTitle                   = { link = "FloatTitle" },
        MiniFilesTitleFocused            = { fg = "${fg}", bg = nil, bold = true },
        MiniHipatternsFixme              = { fg = "${bg}", bg = "${red}", bold = true },
        MiniHipatternsHack               = { fg = "${bg}", bg = "${yellow}", bold = true },
        MiniHipatternsNote               = { fg = "${bg}", bg = "${cyan}", bold = true },
        MiniHipatternsTodo               = { fg = "${bg}", bg = "${blue}", bold = true },
        MiniIconsAzure                   = { fg = "${blue}", bg = nil },
        MiniIconsBlue                    = { fg = "${blue}", bg = nil },
        MiniIconsCyan                    = { fg = "${cyan}", bg = nil },
        MiniIconsGreen                   = { fg = "${green}", bg = nil },
        MiniIconsGrey                    = { fg = "${fg_edge}", bg = nil },
        MiniIconsOrange                  = { fg = "${orange}", bg = nil },
        MiniIconsPurple                  = { fg = "${purple}", bg = nil },
        MiniIconsRed                     = { fg = "${red}", bg = nil },
        MiniIconsYellow                  = { fg = "${yellow}", bg = nil },
        MiniIndentscopeSymbol            = { fg = "${accent}", bg = nil },
        MiniIndentscopeSymbolOff         = { fg = "${red}", bg = nil },
        MiniNotifyBorder                 = { link = "FloatBorder" },
        MiniNotifyLspProgress            = { link = "MiniNotifyNormal" },
        MiniNotifyNormal                 = { link = "NormalFloat" },
        MiniNotifyTitle                  = { link = "FloatTitle" },
        MiniOperatorsExchangeFrom        = { link = "IncSearch" },
        MiniPickBorder                   = { link = "FloatBorder" },
        MiniPickBorderBusy               = { link = "DiagnosticFloatingWarn" },
        MiniPickBorderText               = { link = "FloatTitle" },
        MiniPickCursor                   = { blend = 100, nocombine = true },
        MiniPickIconDirectory            = { link = "Directory" },
        MiniPickIconFile                 = { link = "MiniPickNormal" },
        MiniPickHeader                   = { link = "DiagnosticFloatingHint" },
        MiniPickMatchCurrent             = { link = "CursorLine" },
        MiniPickMatchMarked              = { link = "Visual" },
        MiniPickMatchRanges              = { link = "DiagnosticFloatingHint" },
        MiniPickNormal                   = { link = "NormalFloat" },
        MiniPickPreviewLine              = { link = "CursorLine" },
        MiniPickPreviewRegion            = { link = "IncSearch" },
        MiniPickPrompt                   = { link = "MiniPickMatchRanges" },
        MiniPickPromptCaret              = { link = "DiagnosticFloatingInfo" },
        MiniPickPromptPrefix             = { link = "DiagnosticFloatingInfo" },
        MiniSnippetsCurrent              = { fg = nil, bg = nil, sp = "${yellow}", underdouble = true },
        MiniSnippetsCurrentReplace       = { fg = nil, bg = nil, sp = "${red}", underdouble = true },
        MiniSnippetsFinal                = { fg = nil, bg = nil, sp = "${green}", underdouble = true },
        MiniSnippetsUnvisited            = { fg = nil, bg = nil, sp = "${cyan}", underdouble = true },
        MiniSnippetsVisited              = { fg = nil, bg = nil, sp = "${blue}", underdouble = true },
        MiniStatuslineDevinfo            = { fg = "${bg}", bg = "${fg}" },
        MiniStatuslineFileinfo           = { fg = "${fg}", bg = nil },
        MiniStatuslineFilename           = { fg = nil, bg = nil, blend = 0 },
        MiniStatuslineInactive           = { link = "StatusLineNC" },
        MiniStatuslineModeCommand        = { fg = "${bg}", bg = "${cyan}", bold = true },
        MiniStatuslineModeInsert         = { fg = "${bg}", bg = "${purple}", bold = true },
        MiniStatuslineModeNormal         = { fg = "${bg}", bg = "${fg}", bold = true },
        MiniStatuslineModeOther          = { fg = "${bg}", bg = "${cyan}", bold = true },
        MiniStatuslineModeReplace        = { fg = "${bg}", bg = "${red}", bold = true },
        MiniStatuslineModeVisual         = { fg = "${bg}", bg = "${green}", bold = true },
        MiniSurround                     = { link = "IncSearch" },
        MiniTrailspace                   = { fg = nil, bg = "${red}" },
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
        "live-command",
        event = "DeferredUIEnter",
        after = function()
            require("live-command").setup({
                enable_highlighting = true,
                inline_highlighting = true,
                hl_groups = {
                    insertion = "DiffAdd",
                    deletion = "DiffDelete",
                    change = "DiffChange",
                },
                commands = {
                    Norm = { cmd = "norm" }
                }
            })
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
                    preview = true,
                    width_focus = 35,
                    width_nofocus = 35,
                    width_preview = 35
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
            local mini_icons = require("mini.icons")
            mini_icons.setup()
            mini_icons.tweak_lsp_kind()
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

            local diagnostic_float_step = {
                condition = function()
                    local lnum = vim.fn.line(".") - 1
                    return #vim.diagnostic.get(0, { lnum = lnum }) > 0
                end,
                action = function()
                    vim.schedule(vim.diagnostic.open_float)
                end
            }

            local lsp_hover_step = {
                condition = function() return true end,
                action = function()
                    vim.schedule(vim.lsp.buf.hover)
                end
            }

            local shiftk_steps = { diagnostic_float_step, lsp_hover_step }
            map_multistep('n', 'K', shiftk_steps)
        end
    },
    {
        "mini.notify",
        event = "DeferredUIEnter",
        after = function()
            require("mini.notify").setup({
                lsp_progress = { enable = false }
            })
        end
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
        after = function()
            require("mini.splitjoin").setup({
                detect = {
                    separator = "[,;]",
                }
            })
        end,
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
        "quicker.nvim",
        ft = "qf",
        keys = {
            { "<leader>q", "<Cmd>lua require('quicker').toggle()<cr>", desc = "Toggle quickfix list" },
        },
        after = function()
            ---@module "quicker"
            ---@type quicker.SetupOptions
            require("quicker").setup()
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
