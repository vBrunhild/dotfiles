local create_command = vim.api.nvim_create_user_command

create_command("ZellijPaneNew", "silent !zellij action new-pane", {})
create_command("ZellijTabNew", "silent !zellij action new-tab", {})
