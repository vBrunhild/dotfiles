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
                library = {
                    vim.env.VIMRUNTIME
                },

                checkThirdParty = false
            },
        }
    }
}

