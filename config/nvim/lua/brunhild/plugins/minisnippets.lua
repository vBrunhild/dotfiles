local minisnippets = require('mini.snippets')

local match = function(snips)
    return minisnippets.default_match(snips, { pattern_fuzzy = '%S+' })
end

minisnippets.setup({
    snippets = {
        minisnippets.gen_loader.from_lang()
    },

    mappings = {
        expand = '<C-j>',
    },

    -- Functions describing snippet expansion. If `nil`, default values
    -- are `MiniSnippets.default_<field>()`.
    expand = {
        -- Resolve raw config snippets at context
        prepare = nil,
        -- Match resolved snippets at cursor position
        match = match,
        -- Possibly choose among matched snippets
        select = nil,
        -- Insert selected snippet
        insert = nil,
    }
})
