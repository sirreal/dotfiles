local gl = require("galaxyline")
local colors = require("galaxyline.theme").default
local condition = require("galaxyline.condition")
local gls = gl.section
gl.short_line_list = { "packer" }

gls.left = {
	{
		RainbowRed = {
			provider = function()
				return "▊ "
			end,
			highlight = { colors.blue, colors.bg },
		},
	},
	{
		ViMode = {
			provider = function()
				-- auto change color according the vim mode
				local mode_color = {
					n = colors.red,
					i = colors.green,
					v = colors.blue,
					[""] = colors.blue,
					V = colors.blue,
					c = colors.magenta,
					no = colors.red,
					s = colors.orange,
					S = colors.orange,
					[""] = colors.orange,
					ic = colors.yellow,
					R = colors.violet,
					Rv = colors.violet,
					cv = colors.red,
					ce = colors.red,
					r = colors.cyan,
					rm = colors.cyan,
					["r?"] = colors.cyan,
					["!"] = colors.red,
					t = colors.red,
				}
				vim.api.nvim_command("hi GalaxyViMode guifg=" .. mode_color[vim.fn.mode()] .. " guibg=" .. colors.bg)
				return "●"
			end,
		},
	},

	-- {
	-- 	FileSize = {
	-- 		provider = "FileSize",
	-- 		condition = condition.buffer_not_empty,
	-- 		highlight = { colors.fg, colors.bg },
	-- 	},
	-- },

	-- {
	-- 	FileIcon = {
	-- 		provider = "FileIcon",
	-- 		condition = condition.buffer_not_empty,
	-- 		highlight = { require("galaxyline.provider_fileinfo").get_file_icon_color, colors.bg },
	-- 	},
	-- },

	{
		FileName = {
			-- provider = "FileName",
			provider = function(modified_icon, readonly_icon)
				local function file_readonly(readonly_icon)
					if vim.bo.filetype == "help" then
						return ""
					end
					local icon = readonly_icon or ""
					if vim.bo.readonly == true then
						return " " .. icon .. " "
					end
					return ""
				end

				local file = vim.fn.expand("%:.")
				if vim.fn.empty(file) == 1 then
					return ""
				end
				if string.len(file_readonly(readonly_icon)) ~= 0 then
					return file .. file_readonly(readonly_icon)
				end
				local icon = modified_icon or ""
				if vim.bo.modifiable then
					if vim.bo.modified then
						return file .. " " .. icon .. "  "
					end
				end
				return file .. " "
			end,

			condition = condition.buffer_not_empty,
			highlight = { colors.fg, colors.bg, "bold" },
		},
	},
	{
		LineInfo = {
			provider = "LineColumn",
			separator = " ",
			separator_highlight = { "NONE", colors.bg },
			highlight = { colors.fg, colors.bg },
		},
	},
	{
		PerCent = {
			provider = "LinePercent",
			separator = " ",
			separator_highlight = { "NONE", colors.bg },
			highlight = { colors.fg, colors.bg, "bold" },
		},
	},
	{
		DiagnosticError = {
			provider = "DiagnosticError",
			icon = "  ",
			highlight = { colors.red, colors.bg },
		},
	},
	{
		DiagnosticWarn = {
			provider = "DiagnosticWarn",
			icon = "  ",
			highlight = { colors.yellow, colors.bg },
		},
	},
	-- {
	-- 	DiagnosticHint = {
	-- 		provider = "DiagnosticHint",
	-- 		icon = "  ",
	-- 		highlight = { colors.cyan, colors.bg },
	-- 	},
	-- },
	{
		DiagnosticInfo = {
			provider = "DiagnosticInfo",
			icon = "  ",
			highlight = { colors.blue, colors.bg },
		},
	},
	-- {
	-- 	ShowLspClient = {
	-- 		provider = "GetLspClient",
	-- 		condition = function()
	-- 			local tbl = { ["dashboard"] = true, [""] = true }
	-- 			if tbl[vim.bo.filetype] then
	-- 				return false
	-- 			end
	-- 			return true
	-- 		end,
	-- 		icon = " LSP:",
	-- 		highlight = { colors.yellow, colors.bg, "bold" },
	-- 	},
	-- },
}

gls.right = {
	-- {
	-- 	FileEncode = {
	-- 		provider = "FileEncode",
	-- 		condition = condition.hide_in_width,
	-- 		separator = " ",
	-- 		separator_highlight = { "NONE", colors.bg },
	-- 		highlight = { colors.green, colors.bg, "bold" },
	-- 	},
	-- },

	-- {
	-- 	FileFormat = {
	-- 		provider = "FileFormat",
	-- 		condition = condition.hide_in_width,
	-- 		separator = " ",
	-- 		separator_highlight = { "NONE", colors.bg },
	-- 		highlight = { colors.green, colors.bg, "bold" },
	-- 	},
	-- },
	{
		GitIcon = {
			provider = function()
				return "  "
			end,
			condition = condition.check_git_workspace,
			separator = " ",
			separator_highlight = { "NONE", colors.bg },
			highlight = { colors.violet, colors.bg, "bold" },
		},
	},
	{
		GitBranch = {
			provider = "GitBranch",
			condition = condition.check_git_workspace,
			highlight = { colors.violet, colors.bg, "bold" },
		},
	},
	{
		DiffAdd = {
			provider = "DiffAdd",
			condition = condition.hide_in_width,
			icon = "  ",
			highlight = { colors.green, colors.bg },
		},
	},
	{
		DiffModified = {
			provider = "DiffModified",
			condition = condition.hide_in_width,
			icon = " 柳",
			highlight = { colors.orange, colors.bg },
		},
	},
	{
		DiffRemove = {
			provider = "DiffRemove",
			condition = condition.hide_in_width,
			icon = "  ",
			highlight = { colors.red, colors.bg },
		},
	},
	-- {
	-- 	RainbowBlue = {
	-- 		provider = function()
	-- 			return " ▊"
	-- 		end,
	-- 		highlight = { colors.blue, colors.bg },
	-- 	},
	-- },
}

gls.short_line_left[1] = {
	BufferType = {
		provider = "FileTypeName",
		separator = " ",
		separator_highlight = { "NONE", colors.bg },
		highlight = { colors.blue, colors.bg, "bold" },
	},
}

gls.short_line_left[2] = {
	SFileName = {
		provider = "SFileName",
		condition = condition.buffer_not_empty,
		highlight = { colors.fg, colors.bg, "bold" },
	},
}

gls.short_line_right[1] = {
	BufferIcon = {
		provider = "BufferIcon",
		highlight = { colors.fg, colors.bg },
	},
}
