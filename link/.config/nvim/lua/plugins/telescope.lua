-- local ok, workspaces = pcall(require, "sirreal.local-frecency-workspaces")
-- if not ok then
-- 	workspaces = {}
-- end

-- local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			-- i = {
			-- 	["<esc>"] = actions.close,
			-- },
		},
	},
	extensions = {
		-- frecency = {
		-- 	show_scores = true,
		-- 	show_unindexed = true,
		-- 	workspaces = workspaces,
		-- },
		-- fzf = {
		-- 	-- DEFAULTS --
		-- 	-- fuzzy = true,
		-- 	-- override_generic_sorter = true,
		-- 	-- override_file_sorter = true,
		-- 	-- case_mode = "smart_case",
		-- },
	},
})
-- require("telescope").load_extension("fzf")
-- require("telescope").load_extension("frecency")
