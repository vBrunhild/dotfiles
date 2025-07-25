local function set_python_path(path)
    local clients = vim.lsp.get_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'basedpyright',
    }

    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend(
                'force', client.settings.python or {}, { pythonPath = path }
            )
        else
            client.config.settings = vim.tbl_deep_extend(
                'force', client.config.settings, { python = { pythonPath = path } }
            )
        end

        client.notify('workspace/didChangeConfiguration', { settings = nil })
    end
end

vim.lsp.config('basedpyright', {
    cmd = { "basedpyright-langserver", "--stdio" },
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
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly'
            }
        }
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(
            bufnr, 'SetPythonPath', set_python_path, {
                desc = 'Configure basedpyright with the provided python path',
                nargs = 1,
                complete = 'file'
            }
        )
    end
})

