require("telescope").setup({
	extensions = {
		frecency = {
			show_scores = true,
			show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*" },
			workspaces = {
				-- ["conf"] = "/home/my_username/.config",
				-- ["data"] = "/home/my_username/.local/share",
				-- ["project"] = "/home/my_username/projects",
				-- ["wiki"] = "/home/my_username/wiki",
			},
		},
	},
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("frecency")
