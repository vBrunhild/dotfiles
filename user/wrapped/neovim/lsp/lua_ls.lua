local P = require("nixmodules")

local library = { vim.env.VIMRUNTIME }
for _, path in pairs(P) do
    table.insert(library, path)
end

return {
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
    settings = {
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
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = {
                        'lua/?.lua',
                        'lua/?/init.lua'
                    }
                },
                diagnostics = {
                    globals = { 'vim' }
                },
                workspace = {
                    library = library,
                    checkThirdParty = false
                }
            }
        }
    }
}
