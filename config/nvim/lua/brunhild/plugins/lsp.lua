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

vim.lsp.config('rust_analyzer', {
    --cmd = {},
    settings = {
        ['rust-analyzer'] = {},
    },
})

