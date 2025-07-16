vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = true
})

vim.lsp.enable({
    'rust_analyzer',
    'gopls',
    'nixd',
    'pyright',
    'nil'
})

vim.lsp.inlay_hint.enable(true)

vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
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
        },
    },
})

vim.lsp.config('nixd', {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", "git" }
})

vim.lsp.config('nil', {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", "git" }  
})

