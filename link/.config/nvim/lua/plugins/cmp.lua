local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	formatting = {
		format = lspkind.cmp_format(),
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<Up>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<Down>"] = cmp.mapping.select_next_item(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		--["<S-Tab>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},
	sources = {
		{ group_index = 10, name = "nvim_lsp" },
		-- { name = "nvim_lsp_signature_help" },
		-- { group_index = 20, name = "copilot" },
		-- { group_index = 20, name = "supermaven" },
	},
})
