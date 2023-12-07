local telescope = require("telescope")

telescope.setup({
	defaults = {
		mappings = {
			-- i = {
			-- 	["<esc>"] = actions.close,
			-- },
		},
	},
	extensions = {
		package_info = {},
	},
})
telescope.load_extension("package_info")
