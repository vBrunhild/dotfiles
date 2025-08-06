local library = {
    "lua",
    "${3rd}/luv/library"
}

for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
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
            },
        }
    }
}
