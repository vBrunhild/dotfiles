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

