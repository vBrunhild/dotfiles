local kind_icons = {
	Text = "󰉿",
	Method = "m",
	Function = "󰊕",
	Constructor = "",
	Field = "",
	Variable = "󰆧",
	Class = "󰌗",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰇽",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰊄",
	Codeium = "󰚩",
	Copilot = "",
}

local cmp = require('cmp')
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping(
            function(fallback)
                if vim.fn.pumvisible() == 1 then
                    feedkey("<C-n>", "n")
                elseif cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.jump(1)
                else
                    fallback()
                end
		    end, 
            {"i"}
        ),
		["<S-Tab>"] = cmp.mapping(
            function(fallback)
                if vim.fn.pumvisible() == 1 then
                    feedkey("<C-p>", "n")
                elseif cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
		    end, 
            {"i"}
        ),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	window = {
		documentation = cmp.config.window.bordered(),
		completion = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = ({
				nvim_lsp = "",
				nvim_lua = "",
				luasnip = "",
				buffer = "",
				path = "",
				emoji = "",
			})[entry.source.name]
			return vim_item
		end,
	},
	view = {
		docs = { auto_open = false },
		entries = {
			name = "custom",
			selection_order = "near_cursor",
			follow_cursor = true,
		},
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
		{ name = "path", option = { trailing_slash = true } },
		{ name = "treesitter" },
	}),
})

