if vim.env.PROF then
    require("snacks.profiler").startup({
        startup = {
            event = "VimEnter"
        }
    })
end

require("brunhild.config")
require("brunhild.colors")
require("brunhild.keymaps")
require("brunhild.plugins")
require("brunhild.clipboard")
require("brunhild.autocommands")
require("brunhild.commands")
