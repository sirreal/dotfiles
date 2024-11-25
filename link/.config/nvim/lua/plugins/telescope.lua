local telescope = require("telescope")

telescope.setup({
	defaults = {
		path_display = { "filename_first" },
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
