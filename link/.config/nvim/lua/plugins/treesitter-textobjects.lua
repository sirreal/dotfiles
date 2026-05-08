require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v",
			["@function.outer"] = "V",
			["@class.outer"] = "<c-v>",
		},
		include_surrounding_whitespace = true,
	},
})

local function select(query, group)
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(
			query,
			group or "textobjects"
		)
	end
end

vim.keymap.set({ "x", "o" }, "af", select("@function.outer"), { desc = "outer function" })
vim.keymap.set({ "x", "o" }, "if", select("@function.inner"), { desc = "inner function" })
vim.keymap.set({ "x", "o" }, "as", select("@scope", "locals"), { desc = "language scope" })
