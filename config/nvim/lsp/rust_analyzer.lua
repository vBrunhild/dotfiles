local function reload_workspace(bufnr)
    local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'rust_analyzer' }

    for _, client in ipairs(clients) do
        vim.notify 'Reloading Cargo Workspace'
        client.request('rust-analyzer/reloadWorkspace', nil, function(err)
            if err then
                error(tostring(err))
            end
            vim.notify 'Cargo workspace reloaded'
        end, 0)
    end
end

return {
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

    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
            reload_workspace(bufnr)
        end, { desc = 'Reload current cargo workspace' })
    end,

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
}

