vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = true
})

vim.lsp.enable({
    'rust_analyzer',
    'gopls',
    'pyright',
    'nixd',
    'nil'
})

vim.lsp.inlay_hint.enable(true)

-- Individual lsp configs
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

vim.lsp.config('pyright', {
    cmd = { "pyright-languageserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.cfg",
        "setup.py",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly'
            }
        }
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(
            bufnr, 'SetPythonPath', set_python_path, { nargs = 1, complete = 'file' }
        )
    end
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

-- functions
local function set_python_path(path)
    local clients = vim.lsp.get_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'pyright',
    }

    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend(
                'force', client.settings.python, { pythonPath = path }
            )
        else
            client.config.settings = vim.tbl_deep_extend(
                'force', client.config.settings, { python = { pythonPath = path } }
            )
        end

        client.notify('workspace/didChangeConfiguration', { settings = nil })
    end
end

