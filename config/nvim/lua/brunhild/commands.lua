local create_command = vim.api.nvim_create_user_command

-- Zellij
create_command("ZellijPaneNew", "silent !zellij action new-pane", {})
create_command("ZellijTabNew", "silent !zellij action new-tab", {})
create_command(
    "ZellijTabClose",
    function()
        vim.cmd("normal! wa")
        vim.cmd("silent !zellij action close-tab")
    end,
    {}
)
