return {
    default_config = {
        cmd = { 'golangci-lint-langserver' },
        filetypes = { 'go', 'gomod' },
        init_options = {
            command = { 'golangci-lint', 'run', '--output.json.path=stdout', '--show-stats=false' },
        },
            root_markers = {
            '.golangci.yml',
            '.golangci.yaml',
            '.golangci.toml',
            '.golangci.json',
            'go.work',
            'go.mod',
            '.git',
        },
        before_init = function(_, config)
            local v1
            if vim.fn.executable 'go' == 1 then
                local exe = vim.fn.exepath 'golangci-lint'
                local version = vim.system({ 'go', 'version', '-m', exe }):wait()
                v1 = string.match(version.stdout, '\tmod\tgithub.com/golangci/golangci%-lint\t')
            else
                local version = vim.system({ 'golangci-lint', 'version' }):wait()
                v1 = string.match(version.stdout, 'version v?1%.')
            end
            if v1 then
                config.init_options.command = { 'golangci-lint', 'run', '--out-format', 'json' }
            end
        end,
    }
}

