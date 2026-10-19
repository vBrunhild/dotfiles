local M = {}

local api = vim.api

---@class breadcrumbs.Config
---@field separator string
---@field debounce_ms integer
---@field exclude_filetypes string[]

---@class breadcrumbs.Symbol
---@field name string
---@field kind string? LSP symbol kind name, as understood by `MiniIcons.get("lsp", kind)`

---@class breadcrumbs.LspSymbols
---@field encoding "utf-8"|"utf-16"|"utf-32"
---@field symbols lsp.DocumentSymbol[]|lsp.SymbolInformation[]

---@type breadcrumbs.Config
local config = {
    separator = " > ",
    debounce_ms = 200,
    exclude_filetypes = {},
}

---@type table<integer, breadcrumbs.LspSymbols>
local cache = {}

---@type table<integer, uv.uv_timer_t>
local timers = {}

local winbar = "%{%v:lua.require'breadcrumbs'.render()%}"

---@param buf integer
---@return vim.lsp.Client?
local function lsp_client(buf)
    return vim.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" })[1]
end

---@param buf integer
local function request(buf)
    local client = lsp_client(buf)
    if not client then
        cache[buf] = nil
        return
    end
    local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
    client:request("textDocument/documentSymbol", params, function(err, result)
        if err or not api.nvim_buf_is_valid(buf) then return end
        cache[buf] = { encoding = client.offset_encoding, symbols = result or {} }
        vim.cmd.redrawstatus({ bang = true })
    end, buf)
end

--- Debounced because document symbols are recomputed by the server on every
--- request, and edits arrive far faster than the result is worth refreshing.
---@param buf integer
local function schedule_request(buf)
    if not lsp_client(buf) then return end
    local timer = timers[buf]
    if not timer then
        timer = assert(vim.uv.new_timer())
        timers[buf] = timer
    end
    timer:stop()
    timer:start(config.debounce_ms, 0, vim.schedule_wrap(function()
        if api.nvim_buf_is_valid(buf) then request(buf) end
    end))
end

---@param a lsp.Position
---@param b lsp.Position
---@return boolean
local function is_after(a, b)
    return a.line > b.line or (a.line == b.line and a.character > b.character)
end

---@param range lsp.Range
---@param pos lsp.Position
---@return boolean
local function contains(range, pos)
    return not is_after(range.start, pos) and not is_after(pos, range["end"])
end

--- A private copy of the LSP spec names, indexed by `lsp.SymbolKind`, because
--- `vim.lsp.protocol.SymbolKind` is mutable and `MiniIcons.tweak_lsp_kind()`
--- rewrites it to include glyphs (" Function"), which mini.icons itself then
--- no longer recognises.
---@type string[]
local symbol_kinds = {
    "File", "Module", "Namespace", "Package", "Class", "Method", "Property",
    "Field", "Constructor", "Enum", "Interface", "Function", "Variable",
    "Constant", "String", "Number", "Boolean", "Array", "Object", "Key", "Null",
    "EnumMember", "Struct", "Event", "Operator", "TypeParameter",
}

---@param kind lsp.SymbolKind
---@return string?
local function kind_name(kind)
    return symbol_kinds[kind]
end

--- Servers may answer with a flat `SymbolInformation[]` instead of a tree, so
--- nesting is recovered from range containment: every enclosing symbol, sorted
--- outermost first (earliest start, then widest range).
---@param symbols lsp.SymbolInformation[]
---@param pos lsp.Position
---@return breadcrumbs.Symbol[]
local function flat_path(symbols, pos)
    local enclosing = vim.tbl_filter(function(symbol)
        return contains(symbol.location.range, pos)
    end, symbols)
    table.sort(enclosing, function(a, b)
        local ra, rb = a.location.range, b.location.range
        if is_after(rb.start, ra.start) then return true end
        if is_after(ra.start, rb.start) then return false end
        return is_after(ra["end"], rb["end"])
    end)
    return vim.tbl_map(function(symbol)
        return { name = symbol.name, kind = kind_name(symbol.kind) }
    end, enclosing)
end

---@param symbols lsp.DocumentSymbol[]
---@param pos lsp.Position
---@return breadcrumbs.Symbol[]
local function tree_path(symbols, pos)
    local path = {}
    local level = symbols
    while level do
        local found
        for _, symbol in ipairs(level) do
            if contains(symbol.range, pos) then
                found = symbol
                break
            end
        end
        if not found then break end
        table.insert(path, { name = found.name, kind = kind_name(found.kind) })
        level = found.children
    end
    return path
end

---@param entry breadcrumbs.LspSymbols
---@param win integer
---@return breadcrumbs.Symbol[]
local function lsp_path(entry, win)
    local pos = vim.lsp.util.make_position_params(win, entry.encoding).position
    local symbols = entry.symbols
    if symbols[1] and symbols[1].location then
        ---@cast symbols lsp.SymbolInformation[]
        return flat_path(symbols, pos)
    end
    ---@cast symbols lsp.DocumentSymbol[]
    return tree_path(symbols, pos)
end

--- Node type substrings mapped to LSP kinds. The first match wins, so more
--- specific names go first. "mod_item" is needed because Rust modules never
--- spell out "module".
---@type { [1]: string, [2]: string }[]
local ts_kinds = {
    { "constructor", "Constructor" },
    { "method",      "Method" },
    { "function",    "Function" },
    { "class",       "Class" },
    { "interface",   "Interface" },
    { "trait",       "Interface" },
    { "struct",      "Struct" },
    { "enum",        "Enum" },
    { "impl",        "Class" },
    { "mod_item",    "Module" },
    { "module",      "Module" },
    { "namespace",   "Namespace" },
}

--- Only definition-like nodes count; without the suffix check, nodes such as
--- `function_call` or `class_body` would be picked up as symbols too.
---@param node_type string
---@return string?
local function ts_kind(node_type)
    if not (node_type:match("_definition$") or node_type:match("_declaration$") or node_type:match("_item$")) then
        return nil
    end
    for _, entry in ipairs(ts_kinds) do
        if node_type:find(entry[1], 1, true) then return entry[2] end
    end
end

--- Grammars disagree on where a definition keeps its name: most use a `name`
--- field, C-like grammars bury it at the bottom of a `declarator` chain, and
--- Rust `impl` blocks only have the implemented `type`.
---@param node TSNode
---@param buf integer
---@return string?
local function ts_name(node, buf)
    local target = node:field("name")[1]
    if not target then
        local declarator = node:field("declarator")[1]
        while declarator and declarator:field("declarator")[1] do
            declarator = declarator:field("declarator")[1]
        end
        target = declarator
    end
    if not target and node:type():find("impl", 1, true) then
        target = node:field("type")[1]
    end
    if not target then return nil end
    return (vim.treesitter.get_node_text(target, buf):gsub("%s+", " "))
end

--- Parses on demand because the tree is stale or missing when treesitter
--- highlighting is not running for the buffer. Injections are included so
--- embedded code (e.g. Lua inside Nix strings) still gets a path.
---@param buf integer
---@param win integer
---@return breadcrumbs.Symbol[]
local function ts_path(buf, win)
    local parser = vim.treesitter.get_parser(buf, nil, { error = false })
    if not parser then return {} end
    if not parser:is_valid() then parser:parse() end

    local row, col = unpack(api.nvim_win_get_cursor(win))
    local node = vim.treesitter.get_node({ bufnr = buf, pos = { row - 1, col }, ignore_injections = false })
    local path = {}
    while node do
        local kind = ts_kind(node:type())
        local name = kind and ts_name(node, buf)
        if name then table.insert(path, 1, { name = name, kind = kind }) end
        node = node:parent()
    end
    return path
end

--- mini.icons is optional: without it, or for names it does not know, the
--- segment is rendered as plain text.
---@param category string
---@param name string?
---@return string glyph
---@return string? hl
local function icon(category, name)
    if not MiniIcons or not name then return "", nil end
    local ok, glyph, hl = pcall(MiniIcons.get, category, name)
    if not ok then return "", nil end
    return glyph, hl
end

--- `%` is escaped because the text is interpreted as statusline syntax.
---@param glyph string
---@param hl string?
---@param text string
---@return string
local function segment(glyph, hl, text)
    text = text:gsub("%%", "%%%%")
    if glyph == "" then return text end
    return ("%%#%s#%s%%* %s"):format(hl, glyph, text)
end

--- Winbar expression. `%{}` items are evaluated with the bar's window as the
--- current one, which is more reliable than `g:statusline_winid` (unset on
--- some redraws, e.g. those triggered by LSP handlers).
---@return string
function M.render()
    local win = api.nvim_get_current_win()
    local buf = api.nvim_win_get_buf(win)

    local entry = cache[buf]
    local path = entry and lsp_path(entry, win) or ts_path(buf, win)
    local parts = vim.tbl_map(function(symbol)
        local glyph, hl = icon("lsp", symbol.kind)
        return segment(glyph, hl, symbol.name)
    end, path)

    local separator = "%#BreadcrumbsSeparator#" .. config.separator .. "%*"
    return "%<" .. table.concat(parts, separator)
end

--- Set window-local for the current buffer only, so special buffers later
--- shown in the same window (help, terminals, pickers) don't inherit the bar.
---@param win integer
local function attach(win)
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype ~= ""
        or api.nvim_buf_get_name(buf) == ""
        or api.nvim_win_get_config(win).relative ~= ""
        or vim.tbl_contains(config.exclude_filetypes, vim.bo[buf].filetype)
    then
        return
    end
    vim.wo[win][0].winbar = winbar
end

---@param opts breadcrumbs.Config?
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    api.nvim_set_hl(0, "BreadcrumbsSeparator", { link = "Comment", default = true })

    local group = api.nvim_create_augroup("breadcrumbs", { clear = true })

    -- FileType too, since exclusions depend on a filetype that may only be
    -- detected after the buffer is already displayed.
    api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
        group = group,
        callback = function() attach(api.nvim_get_current_win()) end,
    })

    api.nvim_create_autocmd({ "LspAttach", "BufEnter", "TextChanged", "InsertLeave", "BufWritePost" }, {
        group = group,
        callback = function(args) schedule_request(args.buf) end,
    })

    -- Dropping the cache hands the buffer back to treesitter.
    api.nvim_create_autocmd("LspDetach", {
        group = group,
        callback = function(args) cache[args.buf] = nil end,
    })

    -- The symbol under the cursor can change without anything else
    -- triggering a redraw of the bar.
    api.nvim_create_autocmd("CursorMoved", {
        group = group,
        callback = function() vim.cmd.redrawstatus() end,
    })

    api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(args)
            cache[args.buf] = nil
            if timers[args.buf] then
                timers[args.buf]:close()
                timers[args.buf] = nil
            end
        end,
    })

    -- Lazy-loaded after windows already exist, so attach to those too.
    for _, win in ipairs(api.nvim_list_wins()) do
        attach(win)
        schedule_request(api.nvim_win_get_buf(win))
    end
end

return M
